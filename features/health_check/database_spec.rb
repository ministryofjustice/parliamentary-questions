require 'feature_helper'

describe HealthCheck::Database do
  let(:db) { HealthCheck::Database.new }

  context '#available?' do
    it 'returns true if the database is available' do
      expect(db).to be_available
    end

    it 'returns false if the database is not available' do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(false)

      expect(db).not_to be_available
    end
  end

  context '#accessible?' do
    it 'returns true if the database is accessible with our credentials' do
      expect(db).to be_accessible
    end

    it 'returns false if the database is not accessible with our credentials' do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(false)

      expect(db).not_to be_accessible
    end
  end

  context '#error_messages' do
    it 'returns the exception messages if there is an error accessing the database' do
      allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
      db.available?

      expect(db.error_messages).to eq [
        'Database Error: could not connect to parliamentary-questions_test ' + 
        'on localhost using postgresql'
      ]
    end
  end
end