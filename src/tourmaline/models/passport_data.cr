module Tourmaline::Model
  class PassportData
    include JSON::Serializable

    getter data : Array(EncryptedPassportElement) = [] of Tourmaline::Model::EncryptedPassportElement

    getter credentials : EncryptedCredentials
  end
end
