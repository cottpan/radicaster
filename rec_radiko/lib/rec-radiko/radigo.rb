module Radicaster
  module RecRadiko
    class Radigo
      def initialize(workdir, email = nil, password = nil)
        @workdir = workdir

        raise "email and password must be passed in together" if email.nil? ^ password.nil?
        @email = email
        @password = password
      end

      def rec(area, station, start_time)
        start_str = start_time.strftime("%Y%m%d%H%M%S")
        base = "#{workdir}/#{start_str}-#{station}"
        out = output_path(workdir, start_str, station)

        Dir.glob("#{base}.*").each { |f| File.unlink(f) }

        url = "https://radiko.jp/#!/ts/#{station}/#{start_str}"
        # NOTE:
        # yt-dlp-rajiko は radiko の AAC ストリームを MP4 コンテナ (.m4a) に
        # 格納してダウンロードする。`-x --audio-format aac` を付けても再エンコード
        # されないため、.m4a のまま受け取って後段の ffmpeg に渡す。
        cmd = [
          "yt-dlp",
          "--no-cache-dir",
          "-o", "#{base}.%(ext)s",
        ]
        if !email.nil? && !password.nil?
          cmd.push("-u", email, "-p", password)
        end
        cmd.push(url)
        system(*cmd, exception: true)

        raise "yt-dlp produced no output for #{url}: #{out}" unless File.exist?(out)
        out
      end

      private

      def output_path(workdir, start, station)
        "#{workdir}/#{start}-#{station}.m4a"
      end

      attr_reader :workdir, :email, :password
    end
  end
end
