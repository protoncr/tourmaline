require "halite"
require "mime/multipart"

require "./helpers"
require "./error"
require "./logger"
require "./persistence"
require "./parse_mode"
require "./container"
require "./chat_action"
require "./models/*"
require "./update_action"
require "./update_context"
require "./fiber"
require "./annotations"
require "./filter"
require "./event_handler"
require "./client/*"
require "./markup"
require "./query_result_builder"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add commands and listenters to it.
  class Client
    macro inherited
      include Tourmaline
    end

    include Logger
    include EventHandler::Annotator

    API_URL = "https://api.telegram.org/"

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot_name` to `get_me.username.to_s`.
    getter bot_name : String { get_me.username.to_s }
    getter event_handlers : Array(EventHandler)

    property endpoint_url : String

    # Create a new instance of `Tourmaline::Client`. It is
    # highly recommended to set `@api_key` at an environment
    # variable.
    def initialize(
      @api_key : String,
      @updates_timeout : Int32? = nil,
      @allowed_updates : Array(String)? = nil
    )
      @endpoint_url = Path[API_URL, "bot" + @api_key].to_s

      @event_handlers = [] of EventHandler
      register_event_handlers

      Container.client = self

      if self.is_a?(Persistence)
        self.init_p
        [Signal::INT, Signal::TERM].each do |sig|
          sig.trap { self.cleanup_p; exit }
        end
      end
    end

    def add_event_handler(handler : EventHandler)
      @event_handlers << handler
    end

    private def handle_update(update : Update)
      Log.debug { update.to_pretty_json }

      if self.is_a?(Persistence)
        self.handle_persistent_update(update)
      end

      @event_handlers.each do |handler|
        handler.handle_update(self, update)
      end
    end

    # Sends a json request to the Telegram Client API.
    private def request(method, params = {} of String => String)
      method_url = ::File.join(@endpoint_url, method)
      multipart = includes_media(params)

      if multipart
        config = build_form_data_config(params)
        response = Halite.request(**config, uri: method_url)
      else
        config = build_json_config(params)
        response = Halite.request(**config, uri: method_url)
      end

      result = JSON.parse(response.body)

      if res = result["result"]?
        res.to_json
      else
        handle_error(response.status_code, result["description"].as_s)
      end
    end

    # Parses the status code and returns the right error
    private def handle_error(code, message)
      case code
      when 401..403
        raise Error::Unauthorized.new(message)
      when 400
        raise Error::BadRequest.new(message)
      when 404
        raise Error::InvalidToken.new
      when 409
        raise Error::Conflict.new(message)
      when 413
        raise Error::NetworkError.new("File too large. Check telegram api limits https://core.telegram.org/bots/api#senddocument.")
      when 503
        raise Error::NetworkError.new("Bad gateway")
      else
        raise Error.new("#{message} (#{code})")
      end
    end

    private def object_or_id(object)
      if object.responds_to?(:id)
        return object.id
      end
      object
    end

    private def includes_media(params)
      params.values.any? do |val|
        case val
        when Array
          val.any? { |v| v.is_a?(::File | InputMedia) }
        when ::File, InputMedia
          true
        else
          false
        end
      end
    end

    private def build_json_config(payload)
      {
        verb:    "POST",
        headers: {"Content-Type" => "application/json", "Connection" => "keep-alive"},
        raw:     payload.to_h.compact.to_json, # TODO: Figure out why this is necessary
      }
    end

    private def build_form_data_config(payload)
      boundary = MIME::Multipart.generate_boundary
      formdata = MIME::Multipart.build(boundary) do |form|
        payload.each do |key, value|
          attach_form_value(form, key.to_s, value)
        end
      end

      {
        verb:    "POST",
        headers: {
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Connection"   => "keep-alive",
        },
        raw: formdata,
      }
    end

    private def attach_form_value(form : MIME::Multipart::Builder, id : String, value)
      return unless value
      headers = HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}"}

      case value
      when Array
        # Likely an Array(InputMedia)
        items = value.map do |item|
          if item.is_a?(InputMedia)
            attach_form_media(form, item)
          end
          item
        end
        form.body_part(headers, items.to_json)
      when InputMedia
        attach_form_media(form, value)
        form.body_part(headers, value.to_json)
      when ::File
        filename = ::File.basename(value.path)
        form.body_part(
          HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
          value
        )
      else
        form.body_part(headers, value.to_json)
      end
    end

    private def attach_form_media(form : MIME::Multipart::Builder, value : InputMedia)
      media = value.media
      thumb = value.responds_to?(:thumb) ? value.thumb : nil

      {media: media, thumb: thumb}.each do |key, item|
        item = check_open_local_file(item)
        if item.is_a?(::File)
          id = Random.new.random_bytes(16).hexstring
          filename = ::File.basename(item.path)

          form.body_part(
            HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
            item
          )

          if key == :media
            value.media = "attach://#{id}"
          elsif value.responds_to?(:thumb)
            value.thumb = "attach://#{id}"
          end
        end
      end
    end

    private def check_open_local_file(file)
      if file.is_a?(String)
        if ::File.file?(file)
          return ::File.open(file)
        end
      end
      file
    end
  end
end
