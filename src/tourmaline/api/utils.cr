require "mime"

# Register some of the most common mime-types to avoid any issues.
MIME.register("image/png", ".png")
MIME.register("image/jpeg", ".jpeg")
MIME.register("image/webp", ".webp")
MIME.register("image/gif", ".gif")
MIME.register("image/bmp", ".bmp")
MIME.register("image/x-tga", ".tga")
MIME.register("image/tiff", ".tiff")
MIME.register("image/vnd.adobe.photoshop", ".psd")

MIME.register("video/mp4", ".mp4")
MIME.register("video/quicktime", ".mov")
MIME.register("video/avi", ".avi")

MIME.register("audio/mpeg", ".mp3")
MIME.register("audio/m4a", ".m4a")
MIME.register("audio/aac", ".aac")
MIME.register("audio/ogg", ".ogg")
MIME.register("audio/flac", ".flac")

module Tourmaline::API
  module Utils
    extend self

    USERNAME_RE = /@|(?:https?:\/\/)?(?:www\.)?(?:telegram\.(?:me|dog)|t\.me)\/(joinchat\/)?/

    TG_JOIN_RE = /tg:\/\/(join)\?invite=/

    VALID_USERNAME_RE = /^([a-z]((?!__)[\w\d]){3,30}[a-z\d]|gif|vid|pic|bing|wiki|imdb|bold|vote|like|coub|ya)$/i

    # Gets the display name for the given `User`,
    # `Chat` or `Channel`. Returns `nil` otherwise.
    def get_display_name(entity)
      case entity
      when User
        [entity.last_name, entity.first_name].compact.join(" ")
      when Chat, Channel
        entity.title
      else
        nil
      end
    end

    # Gets the corresponding extension for any Telegram media
    def get_extension(media)
      # Photos are always compressed as .jpg by Telegram
      if get_input_photo(media)
        return ".jpg"
      end

      # These cases are not handled by input photo because it can't
      if media.is_a?(UserProfilePhoto) || media.is_a?(ChatPhoto)
        return ".jpg"
      elsif media.is_a?(MessageMediaDocument)
        media = media.document
      end

      if media.is_a?(Document) ||
          media.is_a?(WebDocument) ||
            media.is_a?(WebDocumentNoProxy)
        if media.mime_type == "application/octet-stream"
          return nil
        else
          return guess_extension(media.mime_type)
        end
      end

      nil
    end

    def get_input_photo(photo)
      if photo.is_a?(InputPhoto)
        return photo
      end

      if photo.is_a?(Message)
        photo = photo.media
      end

      if photo.is_a?(Photo) || photo.is_a?(MessageMediaPhoto)
        photo = photo
      end

      if photo.is_a?(Photo)
        return InputPhoto.new(id: photo.id, access_hash: photo.access_hash,
                              file_reference: photo.file_reference)
      end

      if photo.is_a?(PhotoEmpty)
        return InputPhotoEmpty.new
      end

      if photo.is_a?(ChatFull)
        photo = photo.full_chat
      end

      if photo.is_a?(ChannelFull)
        return get_input_photo(photo.chat_photo)
      elsif photo.is_a?(UserFull)
        return get_input_photo(photo.profile_photo)
      elsif photo.is_a?(Channel) ||
              photo.is_a?(Chat) ||
                photo.is_a?(User)
        return get_input_photo(photo.photo)
      end

      if photo.is_a?(UserEmpty) ||
          photo.is_a?(ChatEmpty) ||
            photo.is_a?(ChatForbidden) ||
              photo.is_a?(ChannelForbidden)
        return InputPhotoEmpty.new
      end

      nil
    end
  end
end
