require "json"

module Tourmaline
  class TFile
    include JSON::Serializable

    getter file_id : String

    getter file_unique_id : String

    getter file_size : Int64?

    getter file_path : String?
  end
end
