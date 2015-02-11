class TokenService
  def generate_token(path, entity, expire)
    token_to_send, token_enc = Devise.token_generator.generate(Token, :token_digest)

    t = Token.find_or_initialize_by(path: path, entity: entity)
    t.update(path: path, entity: entity, expire: expire, token_digest: token_enc)

    token_to_send
  end

  def is_valid(token, path, entity)
    token_dec = Devise.token_generator.digest(Token, :token_digest, token)
    t         = Token.find_by(path: path, entity: entity)
    if t
      DateTime.now < t.expire && Devise.secure_compare(token_dec, t.token_digest)
    else
      false
    end
  end

  def delete_expired
    now_no_time_zone = DateTime.now
    Token.where('expire < ?', now_no_time_zone).destroy_all
  end
end
