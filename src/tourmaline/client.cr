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
require "./annotations"
require "./filter"
require "./event_handler"
require "./client/*"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add event handlers to it.
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
    getter persistence : Persistence

    # Create a new instance of `Tourmaline::Client`. It is
    # highly recommended to set `@api_key` at an environment
    # variable.
    def initialize(@api_key : String,
                   @updates_timeout : Int32? = nil,
                   @allowed_updates : Array(String)? = nil,
                   @persistence : Persistence = NilPersistence.new,
                   endpoint = API_URL)
      @http_client = HTTP::Client.new(URI.parse(endpoint))

      @event_handlers = [] of EventHandler
      register_event_handlers

      Container.client = self

      @persistence.init
      [Signal::INT, Signal::TERM].each do |sig|
        sig.trap { @persistence.cleanup; exit }
      end
    end

    def add_event_handler(handler : EventHandler)
      @event_handlers << handler
    end

    def handle_update(update : Update)
      Log.debug { "Handling update: #{update.to_pretty_json}" }
      handled = [] of String
      @event_handlers.each do |handler|
        unless handled.includes?(handler.group)
          if handler.handle_update(self, update)
            @persistence.handle_update(update)
            handled << handler.group
          end
        end
      end
    end

    # Sends a json request to the Telegram Client API.
    private def request(method, params = {} of String => String)
      path = File.join("/bot" + @api_key, method)
      multipart = includes_media(params)

      Log.debug { "Sending request: #{method}, #{params.to_pretty_json}" }

      if multipart
        config = build_form_data_config(params)
        response = @http_client.exec(**config, path: path)
      else
        config = build_json_config(params)
        response = @http_client.exec(**config, path: path)
      end

      result = JSON.parse(response.body)
      if res = result["result"]?
        res.to_json
      else
        raise Error.from_code(response.status_code, result["description"].as_s)
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
          val.any? { |v| v.is_a?(File | InputMedia) }
        when File, InputMedia
          true
        else
          false
        end
      end
    end

    private def build_json_config(payload)
      {
        method:    "POST",
        headers: HTTP::Headers{"Content-Type" => "application/json", "Connection" => "keep-alive"},
        body:     payload.to_h.compact.to_json,
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
        method:    "POST",
        headers: HTTP::Headers{
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Connection"   => "keep-alive",
        },
        body: formdata,
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
      when File
        filename = File.basename(value.path)
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
        if item.is_a?(File)
          id = Random.new.random_bytes(16).hexstring
          filename = File.basename(item.path)

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
        if File.file?(file)
          return File.open(file)
        end
      end
      file
    end
  end
end
