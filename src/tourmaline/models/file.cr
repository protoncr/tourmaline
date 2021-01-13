module Tourmaline
  class TFile
    include JSON::Serializable
    include Tourmaline::Model

    getter file_id : String

    getter file_unique_id : String

    getter file_size : Int64?

    getter file_path : String?

    def link
      if file_path = @file_path
        File.join("#{API_URL}/file/bot#{@api_key}", file_path)
      end
    end
  end
end
