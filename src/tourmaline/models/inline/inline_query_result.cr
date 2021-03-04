module Tourmaline
  abstract class InlineQueryResult
    include JSON::Serializable
    include Tourmaline::Model

    def self.build(&block)
      builder = Builder.new
      with builder yield builder
      builder.results
    end

    class Builder
      getter results : Array(Tourmaline::InlineQueryResult)

      def initialize
        @results = [] of Tourmaline::InlineQueryResult
      end

      def article(*args, **opts)
        results << InlineQueryResultArticle.new(*args, **opts)
      end

      def audio(*args, **opts)
        results << InlineQueryResultAudio.new(*args, **opts)
      end

      def cached_audio(*args, **opts)
        results << InlineQueryResultCachedAudio.new(*args, **opts)
      end

      def cached_document(*args, **opts)
        results << InlineQueryResultCachedDocument.new(*args, **opts)
      end

      def cached_gif(*args, **opts)
        results << InlineQueryResultCachedGif.new(*args, **opts)
      end

      def cached_mpeg4_gif(*args, **opts)
        results << InlineQueryResultCachedMpeg4Gif.new(*args, **opts)
      end

      def cached_photo(*args, **opts)
        results << InlineQueryResultCachedPhoto.new(*args, **opts)
      end

      def cached_sticker(*args, **opts)
        results << InlineQueryResultCachedSticker.new(*args, **opts)
      end

      def cached_video(*args, **opts)
        results << InlineQueryResultCachedVideo.new(*args, **opts)
      end

      def cached_voice(*args, **opts)
        results << InlineQueryResultCachedVoice.new(*args, **opts)
      end

      def contact(*args, **opts)
        results << InlineQueryResultContact.new(*args, **opts)
      end

      def document(*args, **opts)
        results << InlineQueryResultDocument.new(*args, **opts)
      end

      def gif(*args, **opts)
        results << InlineQueryResultGif.new(*args, **opts)
      end

      def location(*args, **opts)
        results << InlineQueryResultLocation.new(*args, **opts)
      end

      def mpeg4_gif(*args, **opts)
        results << InlineQueryResultMpeg4Gif.new(*args, **opts)
      end

      def photo(*args, **opts)
        results << InlineQueryResultPhoto.new(*args, **opts)
      end

      def venue(*args, **opts)
        results << InlineQueryResultVenue.new(*args, **opts)
      end

      def video(*args, **opts)
        results << InlineQueryResultVideo.new(*args, **opts)
      end

      def game(*args, **opts)
        results << InlineQueryResultGame.new(*args, **opts)
      end
    end
  end
end
