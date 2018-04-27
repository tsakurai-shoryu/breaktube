class Stream
  @@conns = []
  @@queue = []

  def self.conns
    @@conns
  end

  def self.queue
    @@queue
  end

  def self.add_queue(y_id)
    @@queue << y_id
    conns.each do |out|
      params = { type: "select", videoid: @@queue.first}
      out << "data: #{params.to_json}\n\n"
    end
  end

  def self.finish(finished_id)
    db = DataBase.new
    first_switcher = @@queue.first == finished_id
    if first_switcher
      @@queue.shift
      notification_status = "視聴者数 >>> #{conns.count} キュー >>> #{@@queue.count}"
      if @@queue.empty?
        @@queue << db.rand_pick
        notification_text = "次のキューが空なのでこれを再生するよ!!"
      else
        notification_text = "次はこの曲を再生するよ!!"
        notification_text << "その次のキューが空だよ!!" if @@queue.count == 1
      end
      post_stream_notify(notification_text, notification_status, @@queue[0])
      if @@queue.count >= 2
        notification_text = "その次はこの曲を再生する予定だよ!!"
        post_stream_notify(notification_text, "", @@queue[1])
      end
    end
  end

  def self.select_next
    if @@queue.empty?
      db = DataBase.new
      @@queue << db.rand_pick
    end
    @@queue.first
  end

  def self.add_connection(out)
    @@conns << out
    unless(@@queue.empty?)
      params = { type: "select", videoid: @@queue.first}
      out << "data: #{params.to_json}\n\n"
    end
    out.callback { @@conns.delete(out) }
  end

  def self.force_next
    @@conns.each do |out|
      params = { type: "force" }
      out << "data: #{params.to_json}\n\n"
    end
  end
end

Thread.new do
  loop do
    sleep 15
    Strean.conns.each do |out|
      params = { type: "count", count: Stream.conns.count}
      out << "data: #{params.to_json}\n\n"
    end
  end
end
