require 'rails_helper'

RSpec.describe EncryptionService, type: :service do
  let(:data) { 123 }

  it "encrypts and decrypts data correctly" do
    encrypted_data = EncryptionService.encrypt(data)
    expect(EncryptionService.decrypt(encrypted_data)).to eq(data)
  end
end
