class TokenService
  def generate_token(path, entity, expire)
    token_to_send, token_enc = Devise.token_generator.generate(Token, :token_digest)

    t = Token.find_or_initialize_by(path: path, entity: entity)
    t.update(path: path, entity: entity, expire: expire, token_digest: token_enc)

    token_to_send
  end


  def valid?(token, path, entity)
    token_dec = Devise.token_generator.digest(Token, :token_digest, token)
    token = Token.find_by(path: path, entity: entity)
    result = token && Devise.secure_compare(token_dec, token.token_digest) ? true : false
    result
  end


  def expired?(token, path, entity)
    token_dec = Devise.token_generator.digest(Token, :token_digest, token)
    token = Token.find_by(path: path, entity: entity)
    result = token.expire < DateTime.now
    result
  end

  def delete_expired
    now_no_time_zone = DateTime.now
    Token.where('expire < ?', now_no_time_zone).destroy_all
  end

end
