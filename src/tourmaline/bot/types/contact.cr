require "json"

module Tourmaline::Bot

  class Contact

    JSON.mapping(
      phone_number: String,
      first_name:   String,
      last_name:    String?,
      user_id:      Int32?,
    )

  end

end
