module Tourmaline
  class QueryResultBuilder
    getter results : Array(Tourmaline::InlineQueryResult)

    def initialize
      @results = [] of Tourmaline::InlineQueryResult
    end

    def self.build(&block)
      builder = self.new
      yield builder
      builder.results
    end

    def article(**opts)
      results << InlineQueryResultArticle.new(**opts)
    end

    def audio(**opts)
      results << InlineQueryResultAudio.new(**opts)
    end

    def cached_audio(**opts)
      results << InlineQueryResultCachedAudio.new(**opts)
    end

    def cached_document(**opts)
      results << InlineQueryResultCachedDocument.new(**opts)
    end

    def cached_gif(**opts)
      results << InlineQueryResultCachedGif.new(**opts)
    end

    def cached_mpeg4_gif(**opts)
      results << InlineQueryResultCachedMpeg4Gif.new(**opts)
    end

    def cached_photo(**opts)
      results << InlineQueryResultCachedPhoto.new(**opts)
    end

    def cached_sticker(**opts)
      results << InlineQueryResultCachedSticker.new(**opts)
    end

    def cached_video(**opts)
      results << InlineQueryResultCachedVideo.new(**opts)
    end

    def cached_voice(**opts)
      results << InlineQueryResultCachedVoice.new(**opts)
    end

    def contact(**opts)
      results << InlineQueryResultContact.new(**opts)
    end

    def document(**opts)
      results << InlineQueryResultDocument.new(**opts)
    end

    def gif(**opts)
      results << InlineQueryResultGif.new(**opts)
    end

    def location(**opts)
      results << InlineQueryResultLocation.new(**opts)
    end

    def mpeg4_gif(**opts)
      results << InlineQueryResultMpeg4Gif.new(**opts)
    end

    def photo(**opts)
      results << InlineQueryResultPhoto.new(**opts)
    end

    def venue(**opts)
      results << InlineQueryResultVenue.new(**opts)
    end

    def video(**opts)
      results << InlineQueryResultVideo.new(**opts)
    end
  end
end
