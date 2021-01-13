module Tourmaline
  class PassportData
    include JSON::Serializable
    include Tourmaline::Model

    getter data : Array(EncryptedPassportElement) = [] of Tourmaline::EncryptedPassportElement

    getter credentials : EncryptedCredentials
  end
end
