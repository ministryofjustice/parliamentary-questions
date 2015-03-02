require 'spec_helper'

describe TokenService do
  let(:expire_in_future) { DateTime.new(2100, 01, 20, 10, 0, 0) }
  let(:expire_in_past) { DateTime.new(2013, 01, 20, 10, 0, 0) }

  describe '#generate_token' do
    it 'should generate a token and store the token digest in the database' do
      token_to_send = subject.generate_token('/path/one', 'entity_one', expire_in_future)

      expect(token_to_send).to_not be nil

      token_entry = Token.find_by(path: '/path/one')

      expect(token_entry.expire).to eq expire_in_future
      expect(token_entry.token_digest).to_not be nil
      expect(token_entry.entity).to eq('entity_one')
    end

    it 'should store only one token for the same path and entity' do
      subject.generate_token('/path/one', 'entity_one', expire_in_future)
      subject.generate_token('/path/one', 'entity_one', expire_in_future)

      tokens = Token.where(path: '/path/one',  entity: 'entity_one')

      expect(tokens.size).to eq(1)
    end

  end

  describe '#is_valid' do
    it 'should return true if valid token is provided' do
      token_to_send = subject.generate_token('/path/one', 'entity_one', expire_in_future)

      is_valid = subject.is_valid(token_to_send, '/path/one', 'entity_one')
      expect(is_valid).to eq(true)
    end

    it 'should return false if the token is not correct' do
      subject.generate_token('/path/one', 'entity_one', expire_in_future)

      is_valid = subject.is_valid('invalid', '/path/one', 'entity_one')

      expect(is_valid).to eq(false)
    end

    it 'should return false if the path is not correct' do
      token_to_send = subject.generate_token('/path/one', 'entity_one', expire_in_future)

      is_valid = subject.is_valid(token_to_send, '/invalid', 'entity_one')

      expect(is_valid).to eq(false)
    end

    it 'should return false if the entity is not correct' do
      token_to_send = subject.generate_token('/path/one', 'entity_one', expire_in_future)

      is_valid = subject.is_valid(token_to_send, '/path/one', 'invalid')

      expect(is_valid).to eq(false)
    end


    it 'should return false if token expired' do
      token_to_send = subject.generate_token('/path/one', 'entity_one', expire_in_past)

      is_valid = subject.is_valid(token_to_send, '/path/one', 'entity_one')

      expect(is_valid).to eq(false)
    end


    it 'should be valid only the last token generated given a path, entity' do
      first_token = subject.generate_token('/path/one', 'entity_one', expire_in_future)
      second_token = subject.generate_token('/path/one', 'entity_one', expire_in_future)

      invalid = subject.is_valid(first_token, '/path/one', 'entity_one')
      valid = subject.is_valid(second_token, '/path/one', 'entity_one')

      expect(invalid).to eq(false)
      expect(valid).to eq(true)
    end
  end

  describe '#delete_expired' do
    it 'should delete expired tokens' do
      subject.generate_token('/path/one', 'entity_one', expire_in_past)
      subject.generate_token('/path/two', 'entity_one', expire_in_past)

      subject.generate_token('/path/three', 'entity_one', expire_in_future)

      tokens = Token.where(entity: 'entity_one')
      expect(tokens.size).to eq(3)

      subject.delete_expired
      tokens = Token.where(entity: 'entity_one')
      expect(tokens.size).to eq(1)
    end
  end
end
