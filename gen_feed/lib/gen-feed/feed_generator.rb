require "erb"
require "pathname"

module Radicaster
  module GenFeed
    class FeedGenerator
      def generate(definition, episodes)
        escape = ->(value) { ERB::Util.html_escape(value.to_s) }
        open(Pathname.new(__FILE__).join("../templates/podcast.xml.erb").expand_path) do |f|
          ERB.new(f.read).result(binding)
        end
      end
    end
  end
end
