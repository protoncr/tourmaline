module Tourmaline
  class PassportData
    include JSON::Serializable

    getter data : Array(EncryptedPassportElement) = [] of Tourmaline::EncryptedPassportElement

    getter credentials : EncryptedCredentials
  end
end
