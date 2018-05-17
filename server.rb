require 'sinatra'
require 'slack-ruby-client'
require 'dotenv'
require 'thin'
require './lib/tools.rb'
require './lib/database.rb'

set server: "thin", connections: [], history_file: "history.yml"
set :public_folder, File.dirname(__FILE__) + '/public'

help =<<EOS
breaktubeとは？

みんなが自由に追加することができるプレイリストのようなものです。
`/breaktube` => リストからランダムに再生。
`/breaktube lastest10` => 最新追加10曲からランダムに再生。数字部分は変更可能。
`/breaktube add=ID` => 動画のリンクをadd=の後ろに入力するとbreaktubeに動画を追加。
`/breaktube count` => 今breaktubeに登録されている曲数がわかる。
`/breaktube user_ranking` => breaktubeに曲を登録した数のランキングTOP10が確認できます。
EOS

Dotenv.load

Slack.configure do |config|
  config.token = ENV["S_TOKEN"]
end

conns = []
queue = []

def picked(y_id, conns, queue, channel)
  db = DataBase.new
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
  if channel == "breaktube" or channel == "breaktube-log"
    y_id = db.short_video_pick
    queue << y_id
    conns.each do |out|
      params = { type: "select", videoid: queue.first}
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

get '/next' do
  db = DataBase.new
  finished_id = params[:videoid]
  first_switcher = queue.first == finished_id
  if first_switcher
#    db.finishlists_insert(queue[0])
    queue.shift
    notification_status = "視聴者数 >>> #{conns.count} キュー >>> #{queue.count}"
    if queue.empty?
      queue << db.short_video_pick
      notification_text = "次のキューが空なのでこれを再生するよ!!"
    else
      notification_text = "次はこの曲を再生するよ!!"
      notification_text << "その次のキューが空だよ!!" if queue.count == 1
    end
    post_stream_notify(notification_text, notification_status, queue[0])
    if queue.count >= 2
      notification_text = "その次はこの曲を再生する予定だよ!!"
      post_stream_notify(notification_text, "", queue[1])
    end
  end
  queue.first
end

get '/subscribe', provides: 'text/event-stream' do
  stream(:keep_open) do |out|
    conns << out
    unless(queue.empty?)
      params = { type: "select", videoid: queue.first}
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
    channel = params[:channel_name]
    return picked(y_id, conns, queue, channel)


  when "user_ranking" then
    return message_response(db.ranking_pick)

  # 'latest' or 'lastest'
  when /las?test/ then
    sample_count = [params[:text][/las?test(\d+)/,1].to_i, db.playlists_count].min
    y_id = db.rand_pick(range: sample_count)
    channel = params[:channel_name]
    return picked(y_id, conns, queue, channel)

  when /add=/ then
    y_id = params[:text][/add=(https:\/\/www.youtube.com\/watch\?v=|https:\/\/youtu.be\/|)([a-zA-Z0-9_\-]+)/,2]
    return message_response("不正なIDです。") if y_id.nil?
    uname = params[:user_name]

    if db.youtube_id_search?(y_id)
      queue << y_id if check_video_seconds(y_id) <= 600
      return message_response("すでに存在するIDです。")
    end
    return message_response("youtubeに存在しないIDです。") unless link_check?(y_id)

    db.playlists_insert(user_name = uname, youtube_id = y_id)
    slack_cl.chat_postMessage(channel: "breaktube-log", text: "#{params[:user_name]} added #{y_id}")
    queue << y_id
    return message_response("ID追加に成功しました。")

  when /help/ then
    return message_response(help)

  when "force" then
    if params[:channel_name] != "breaktube"
      return message_response("このチャンネルでは利用できないコマンドです。")
    end
    conns.each do |out|
      params = { type: "force" }
      out << "data: #{params.to_json}\n\n"
    end
    return message_response("強制的に切り替えたよ。")

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

get '/grid' do
  @list = DataBase.new.all
  erb :grid
end

get '/list' do
  @list = DataBase.new.all
  erb :list
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
