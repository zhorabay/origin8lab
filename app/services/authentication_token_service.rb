require 'jwt'

class AuthenticationTokenService
  HMAC_SECRET = ENV.fetch('HMAC_SECRET')

  def self.encode(user_id, hmac_secret)
    payload = { user_id: user_id }
    JWT.encode(payload, hmac_secret, 'HS256')
  end

  def self.decode(token)
    decoded_token = JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' })
    decoded_token.first['user_id']
  end
end
