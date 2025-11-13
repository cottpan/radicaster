module Radicaster
  module GenFeed
    # Podcastの定義
    class Definition
      attr_reader :title, :author, :summary, :image, :rss_program_limit

      def initialize(title:, author: nil, summary: nil, image: nil, rss_program_limit: nil)
        @title = title
        @author = author
        @summary = summary
        @image = image
        @rss_program_limit = rss_program_limit
      end
    end
  end
end
