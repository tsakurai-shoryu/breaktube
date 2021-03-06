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

def check_title(youtube_id)
  uri = URI.parse("https://www.googleapis.com/youtube/v3/videos?id=#{youtube_id}&key=#{ENV["Y_APIKEY"]}&part=snippet")
  result = JSON.parse(Net::HTTP.get(uri))
  result.dig("items", 0, "snippet", "title")
end

def check_video_seconds(youtube_id)
  uri = URI.parse("https://www.googleapis.com/youtube/v3/videos?id=#{youtube_id}&key=#{ENV["Y_APIKEY"]}&part=contentDetails")
  result = JSON.parse(Net::HTTP.get(uri))
  video_time = result["items"][0]["contentDetails"]["duration"].delete("PT").gsub(/(\d+?[A-Z])/,'\0 ').split
  video_time.map! do |s|
    if s.include?("H")
      s.delete("H").to_i*3600
    elsif s.include?("M")
      s.delete("M").to_i*60
    else
      s.delete("S").to_i
    end
  end
  video_time.sum
end

def post_stream_notify(notification_text, notification_status, youtube_id)
  db = DataBase.new
  atta = [
    {
      "fallback": "Required plain-text summary of the attachment.",
      "color": "#36a64f",
      "pretext": notification_text,
      "title": db.get_title(youtube_id),
      "title_link": "https://www.youtube.com/watch?v=#{youtube_id}",
      "text": notification_status,
      "thumb_url": "http://i.ytimg.com/vi/#{youtube_id}/default.jpg"
    }
  ].to_json
  slack_cl = Slack::Web::Client.new
  slack_cl.chat_postMessage(channel: "breaktube", unfurl_media: false, attachments: atta)
end
