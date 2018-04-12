require 'sinatra'
require 'slack-ruby-client'
require 'dotenv'
require './lib/tools.rb'
require './lib/database.rb'

help =<<EOS
breaktubeとは？

みんなが自由に追加することができるプレイリストのようなものです。
`/breaktube` => リストからランダムに再生
`/breaktube add=ID` => 動画のリンクをadd=の後ろに入力するとbreaktubeに動画を追加
`/breaktube count` => 今breaktubeに登録されている曲数がわかる
EOS

Dotenv.load

Slack.configure do |config|
  config.token = ENV["S_TOKEN"]
end

post '/' do
  content_type :json
  p params
  slack_cl = Slack::Web::Client.new
  db = DataBase.new

  case params[:text]

  when "" then
    y_id = db.rand_pick
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
    return message_response(
             "この動画を評価してね！\n https://www.youtube.com/watch?v=#{y_id}",
             attachments: atta
           )

  when "lastest" then
    range = params[:text][/lastest(\d+)/,1].to_i
    y_id = db.rand_pick(range)
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
    return message_response(
             "この動画を評価してね！\n https://www.youtube.com/watch?v=#{y_id}",
             attachments: atta
           )

  when /add=/ then
    y_id = params[:text][/add=(https:\/\/www.youtube.com\/watch\?v=|https:\/\/youtu.be\/|)([a-zA-Z0-9_\-]+)/,2]
    return message_response("不正なIDです。") if y_id.nil?
    uname = params[:user_name]
    if db.youtube_id_search?(y_id) and link_check?(y_id)
      db.playlists_insert(user_name = uname, youtube_id = y_id)
      slack_cl.chat_postMessage(channel: "breaktube-log", text: "#{params[:user_name]} added #{y_id}")
      return message_response("ID追加に成功しました。")
    else
      return message_response("すでに存在するIDです。") unless db.youtube_id_search?(y_id)
      return message_response("youtubeに存在しないIDです。") unless link_check?(y_id)
    end

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
