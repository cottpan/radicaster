require "yaml"

module Radicaster
  module GenFeed
    class S3
      FEED_FILENAME = "index.rss"
      DEFINITION_FILENAME = "radicaster.yaml"
      EPISODE_EXTS = [".m4a"]

      def initialize(client, bucket, url)
        @client = client
        @bucket = bucket
        @url = url
      end

      def find_definition(id)
        key = "#{id}/#{DEFINITION_FILENAME}"
        resp = client.get_object(bucket: bucket, key: key)
        def_hash = YAML.load(resp.body.read)
        Definition.new(
          title: def_hash["title"],
          author: def_hash["author"],
          summary: def_hash["summary"],
          image: def_hash["image"],
          rss_program_limit: def_hash["rss_program_limit"],
        )
      end

      def list_episodes(id, limit: nil)
        prefix = id + "/"
        resp = client.list_objects_v2(bucket: bucket, prefix: prefix)
        episodes = resp
          .contents
          .filter { |c| EPISODE_EXTS.include?(Pathname.new(c.key).extname) }
          .map { |c|
          Episode.new(
            url: build_public_url(c.key),
            size: c.size,
            last_modified: c.last_modified,
          )
        }
          .sort_by(&:title)
          .reverse
        
        # limitが指定されている場合は、その数だけ返す
        limit ? episodes.take(limit) : episodes
      end

      def save_feed(id, feed_body)
        key = "#{id}/#{FEED_FILENAME}"
        client.put_object(
          bucket: bucket,
          key: key,
          body: feed_body,
        )
      end

      # 全てのエピソードを取得（limit無し）
      def list_all_episodes(id)
        prefix = id + "/"
        resp = client.list_objects_v2(bucket: bucket, prefix: prefix)
        resp
          .contents
          .filter { |c| EPISODE_EXTS.include?(Pathname.new(c.key).extname) }
          .map { |c|
          {
            key: c.key,
            url: build_public_url(c.key),
            size: c.size,
            last_modified: c.last_modified,
            storage_class: c.storage_class,
          }
        }
          .sort_by { |ep| ep[:last_modified] }
          .reverse
      end

      # 上限を超えた古いエピソードをアーカイブストレージクラスに移行
      def archive_old_episodes(id, limit)
        all_episodes = list_all_episodes(id)
        
        # limitを超えるエピソードを取得
        episodes_to_archive = all_episodes.drop(limit)
        
        episodes_to_archive.each do |ep|
          # 既にGLACIERまたはDEEP_ARCHIVEの場合はスキップ
          next if ["GLACIER", "DEEP_ARCHIVE"].include?(ep[:storage_class])
          
          # GLACIER_IRに移行（即座にアクセス可能な低コストストレージ）
          client.copy_object(
            bucket: bucket,
            copy_source: "#{bucket}/#{ep[:key]}",
            key: ep[:key],
            storage_class: "GLACIER_IR",
            metadata_directive: "COPY",
          )
        end
        
        episodes_to_archive.size
      end

      private

      attr_reader :client, :bucket, :url

      def build_public_url(key)
        "#{url}/#{key}"
      end
    end
  end
end
