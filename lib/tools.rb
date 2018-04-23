require 'net/http'
require 'uri'
require 'json'
require 'dotenv'


def message_response(text, attachments: "", response_type: "in_channel")
  p response_type
  {
    "content_type" =>"application/json",
    "response_type" => "#{response_type}",
    "replace_original" => false,
    "text" => text,
    "attachments" => attachments
  }.to_json
end


def link_check?(youtube_id)
  uri = URI.parse("https://www.googleapis.com/youtube/v3/videos?id=#{youtube_id}&key=#{ENV["Y_APIKEY"]}&part=status")
  result = JSON.parse(Net::HTTP.get(uri))
  result["items"].size > 0
end

def get_title(youtube_id)
  uri = URI.parse("https://www.googleapis.com/youtube/v3/videos?id=#{youtube_id}&key=#{ENV["Y_APIKEY"]}&part=status")
  result = JSON.parse(Net::HTTP.get(uri))
  result["items"][0]["snippet"]["title"]
end
