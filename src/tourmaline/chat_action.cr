module Tourmaline
  # Chat actions are what appear at the top of the screen
  # when users are typing, sending files, etc. You can
  # mimic these actions by using the
  # `Client#send_chat_action` method.
  enum ChatAction
    Typing
    UploadPhoto
    RecordVideo
    UploadVideo
    RecordAudio
    UploadAudio
    UploadDocument
    Findlocation
    RecordVideoNote
    UploadVideoNote

    def to_s
      super.to_s.underscore
    end
  end
end
