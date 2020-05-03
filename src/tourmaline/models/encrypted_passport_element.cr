require "json"

module Tourmaline
  class EncryptedPassportElement
    include JSON::Serializable

    getter type : String # TODO: Make EncryptedPassportElement::Type

    getter data : String?

    getter phone_number : String?

    getter email : String?

    getter files : Array(PassportFile) = [] of Tourmaline::PassportFile

    getter front_side : Array(PassportFile) = [] of Tourmaline::PassportFile

    getter reverse_side : Array(PassportFile) = [] of Tourmaline::PassportFile

    getter selfie : PassportFile?

    getter translation : Array(PassportFile) = [] of Tourmaline::PassportFile

    getter hash : String

    enum Type
      PersonalDetails
      Passport
      DriverLicense
      IdentityCard
      InternalPassport
      Address
      UtilityBill
      BankStatement
      RentalAgreement
      PassportRegistration
      TemporaryRegistration
      PhoneNumber
      Email
    end
  end
end
