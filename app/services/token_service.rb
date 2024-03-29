class TokenService
  def generate_token(path, entity, expire)
    token_to_send, token_enc = Devise.token_generator.generate(Token, :token_digest)

    t = Token.find_or_initialize_by(path:, entity:)
    t.update!(path:, entity:, expire:, token_digest: token_enc)

    token_to_send
  end

  def valid?(token, path, entity)
    token_dec = Devise.token_generator.digest(Token, :token_digest, token)
    token = Token.find_by(path:, entity:)
    token && Devise.secure_compare(token_dec, token.token_digest) ? true : false
  end

  def expired?(token, path, entity)
    Devise.token_generator.digest(Token, :token_digest, token)
    token = Token.find_by(path:, entity:)
    token.expire < Time.zone.now
  end

  def delete_expired
    now_no_time_zone = Time.zone.now
    Token.where("expire < ?", now_no_time_zone).destroy_all
  end
end
