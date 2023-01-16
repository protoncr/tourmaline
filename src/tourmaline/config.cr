module Tourmaline
  module Config
    DEFAULT_API_ENDPOINT     = "https://api.telegram.org/"
    DEFAULT_COMMAND_PREFIXES = ["/"]

    # The API token given to you by @BotFather on Telegram
    class_property! api_token : String

    # The default prefixes to use for all commands which don't override this value
    class_property command_prefixes : Array(String) = DEFAULT_COMMAND_PREFIXES

    # The parse mode to use by default for all messages which don't override this value
    class_property parse_mode : ParseMode = ParseMode::Markdown

    # The bot API endpoint to use
    class_property api_endpoint : String = DEFAULT_API_ENDPOINT

    # Whether or not to use a proxy
    class_property proxy : Bool = false

    # URI to use for proxying requests
    class_property! proxy_uri : String? | URI?

    # Host to use for proxying requests
    class_property! proxy_host : String?

    # Port to use for proxying requests
    class_property! proxy_port : Int32?

    # Username to use for proxying requests
    class_property! proxy_user : String?

    # Password to use for proxying requests
    class_property! proxy_pass : String?
  end
end
