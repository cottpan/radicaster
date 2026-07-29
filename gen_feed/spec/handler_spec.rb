module Radicaster::GenFeed
  describe Handler do
    let(:logger) { double("logger", info: nil, debug: nil) }
    let(:storage) { double("storage") }
    let(:generator) { double("generator") }
    let(:handler) { Handler.new(logger, storage, generator) }

    def s3_event(key)
      {
        "Records" => [
          {
            "eventName" => "ObjectCreated:Put",
            "s3" => {
              "bucket" => {
                "name" => "dummy-bucket",
              },
              "object" => {
                "key" => key,
              },
            },
          },
        ],
      }
    end

    describe "#handle" do
      it "generates a feed for m4a object events" do
        definition = Definition.new(title: "dummy title", rss_program_limit: 5)
        episodes = [
          Episode.new(url: "https://radicaster.test/dummy/20210102.m4a", size: 100, last_modified: Time.utc(2021, 1, 2)),
        ]

        expect(storage).to receive(:find_definition).with("dummy").and_return(definition)
        expect(storage).to receive(:list_episodes).with("dummy", limit: 5).and_return(episodes)
        expect(generator).to receive(:generate).with(definition, episodes).and_return("feed")
        expect(storage).to receive(:save_feed).with("dummy", "feed")

        handler.handle(event: s3_event("dummy/20210102.m4a"), context: nil)
      end

      it "ignores feed object events to avoid recursive invocation" do
        expect(storage).not_to receive(:find_definition)
        expect(storage).not_to receive(:list_episodes)
        expect(generator).not_to receive(:generate)
        expect(storage).not_to receive(:save_feed)

        handler.handle(event: s3_event("dummy/index.rss"), context: nil)
      end

      it "logs the S3 trigger summary" do
        expect(logger).to receive(:info).with("Trigger: s3 event_name=ObjectCreated:Put bucket=dummy-bucket key=dummy/20210102.m4a")

        allow(storage).to receive(:find_definition).and_return(Definition.new(title: "dummy title"))
        allow(storage).to receive(:list_episodes).and_return([])
        allow(generator).to receive(:generate).and_return("feed")
        allow(storage).to receive(:save_feed)

        handler.handle(event: s3_event("dummy/20210102.m4a"), context: nil)
      end
    end
  end
end
