# app/services/encryption_service.rb
class EncryptionService
  def self.encrypt(data)
    crypt = encryptor
    Base64.urlsafe_encode64(crypt.encrypt_and_sign(data.to_s))
  end

  def self.decrypt(data)
    crypt = encryptor
    decoded_data = Base64.urlsafe_decode64(data)
    crypt.decrypt_and_verify(decoded_data).to_i
  end

  private

  def self.encryptor
    key = Base64.decode64(Rails.application.credentials[:encryption_key])
    ActiveSupport::MessageEncryptor.new(key)
  end
end
