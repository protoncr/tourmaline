module Tourmaline
  class Client
    module UserMethods
      def login(phone_number)
        res = request(JSON::Any, "login", {phone_number: phone_number})
        @user_token = res["token"].as_s
      end

      def send_code(code)
        res = request(JSON::Any, "authcode", {code: code.to_i})
        res["authorization_state"].as_s == "ready"
      end

      def ping
        request(Float64, "ping")
      end
    end
  end
end
