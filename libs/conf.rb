require 'yaml'

class Conf
  def self.[](key)
    ENV[key] || conf[key]
  end

  def self.conf
    begin
      @@conf ||= YAML::load self.open.read
    rescue => e
      STDERR.puts e
      STDERR.puts "設定ファイルがみつからないよ"
      exit 1
    end
  end

  def self.open
    File.open(self.file)
  end

  def self.file
    @@file ||= File.dirname(__FILE__)+'/../config.yml'
  end
end