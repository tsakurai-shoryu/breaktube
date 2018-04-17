require 'sinatra'
require 'slack-ruby-client'
require 'dotenv'
require 'thin'
require './lib/tools.rb'
require './lib/database.rb'

set server: "thin", connections: [], history_file: "history.yml"

help =<<EOS
breaktubeとは？

みんなが自由に追加することができるプレイリストのようなものです。
`/breaktube` => リストからランダムに再生。
`/breaktube lastest10` => 最新追加10曲からランダムに再生。数字部分は変更可能。
`/breaktube add=ID` => 動画のリンクをadd=の後ろに入力するとbreaktubeに動画を追加。
`/breaktube count` => 今breaktubeに登録されている曲数がわかる。
EOS

Dotenv.load

Slack.configure do |config|
  config.token = ENV["S_TOKEN"]
end

conns = []
lastest_ids = []

def picked(y_id, conns, lastest_ids, channel)
  atta = [
    {
      text: "ボタンを選択してください",
      fallback: "評価を受け付けました",
      callback_id: "review=#{y_id}",
      color: "#3AA3E3",
      attachment_type: "default",
      actions: [
        {
          name: "vote",
          text: "Up vote :+1:",
          type: "button",
          value: "upvote"
        },
        {
          name: "vote",
          text: "Down vote :-1:",
          type: "button",
          value: "downvote"
        }
      ]
    }
  ]
  p atta
  if channel == "breaktube"
    lastest_ids = [y_id]
    conns.each do |out|
      params = { type: "select", videoid: lastest_ids[0]}
      out << "data: #{params.to_json}\n\n"
    end
  end
  message_response(
           "この動画を評価してね！\n https://www.youtube.com/watch?v=#{y_id}",
           attachments: atta
         )
end

get '/' do
  erb :index
end

get '/subscribe', provides: 'text/event-stream' do
  stream(:keep_open) do |out|
    conns << out
    if(lastest_ids[0] != "")
      params = { type: "select", videoid: lastest_ids[0]}
      out << "data: #{params.to_json}\n\n"
    end
    out.callback { conns.delete(out) }
  end
end

post '/' do
  content_type :json
  p params
  slack_cl = Slack::Web::Client.new
  db = DataBase.new

  case params[:text]

  when "" then
    y_id = db.rand_pick
    channnel = params[:channel_name]
    return picked(y_id, conns, lastest_ids, channel)

  when /lastest/ then
    sample_count = [params[:text][/lastest(\d+)/,1].to_i, db.playlists_count].min
    y_id = db.rand_pick(range: sample_count)
    return picked(y_id, conns, lastest_ids)

  when /add=/ then
    y_id = params[:text][/add=(https:\/\/www.youtube.com\/watch\?v=|https:\/\/youtu.be\/|)([a-zA-Z0-9_\-]+)/,2]
    return message_response("不正なIDです。") if y_id.nil?
    uname = params[:user_name]

    return message_response("すでに存在するIDです。") unless db.youtube_id_search?(y_id)
    return message_response("youtubeに存在しないIDです。") unless link_check?(y_id)

    db.playlists_insert(user_name = uname, youtube_id = y_id)
    slack_cl.chat_postMessage(channel: "breaktube-log", text: "#{params[:user_name]} added #{y_id}")
    return message_response("ID追加に成功しました。")

  when /help/ then
    return message_response(help)

  when /count/ then
    return message_response(db.playlists_count)

  else
    return message_response("不正な値です。")
  end
end

post '/results' do
  content_type :json
  results = JSON.parse(params[:payload])
  p results
  slack_cl = Slack::Web::Client.new

  case results["callback_id"]
  when /review=/
    y_id = results["callback_id"][/review=(.+)/,1]
    uname = results["user"]["name"]
    vote = results["actions"][0]["value"]
    p message_response("ありがとう！\n#{uname}のレビューを受け付けたよ！(選択したレビュー：#{vote}",
                       response_type: "ephemeral")
    return message_response("ありがとう！\n#{uname}のレビューを受け付けたよ！(選択したレビュー：#{vote}",
                            response_type: "ephemeral")
  else
    "不正な値です。bot管理者に連絡してください。"
  end
  ""
end

Thread.new do
  loop do
    sleep 15
    conns.each do |out|
      params = { type: "count", count: conns.count}
      out << "data: #{params.to_json}\n\n"
    end
  end
end
