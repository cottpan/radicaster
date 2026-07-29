module Radicaster::RecRadiko
  describe Radigo do
    let(:workdir) { "/tmp" }

    describe "#initialize" do
      context "normal caess" do
        where(:email, :password) do
          [
            [nil, nil],
            ["test@radicaster.test", "password"],
          ]
        end

        with_them do
          it "does not raise error" do
            expect { Radigo.new(workdir, email, password) }.to_not raise_error
          end
        end
      end

      context "abnormal cases" do
        where(:email, :password) do
          [
            ["test@radicaster.net", nil],
            [nil, "password"],
          ]
        end

        with_them do
          it "raises RuntimeError" do
            expect { Radigo.new(workdir, email, password) }.to raise_error(RuntimeError)
          end
        end
      end
    end

    describe "#rec" do
      let(:area) { "JP13" }
      let(:id) { "TEST" }
      let(:start_time) { Time.new(2020, 11, 22, 1, 0, 0, "+09:00") }
      let(:url) { "https://radiko.jp/#!/ts/TEST/20201122010000" }
      let(:output_template) { "/tmp/20201122010000-TEST.%(ext)s" }
      let(:output_path) { "/tmp/20201122010000-TEST.m4a" }

      context "when credentials are not specified" do
        subject(:radiko) { Radigo.new(workdir) }
        it "executes yt-dlp without credentials" do
          allow(radiko).to receive(:system)
          allow(Dir).to receive(:glob).with("/tmp/20201122010000-TEST.*").and_return([output_path])
          allow(File).to receive(:unlink).with(output_path)
          allow(File).to receive(:exist?).with(output_path).and_return(true)

          ret = radiko.rec(area, id, start_time)

          expect(ret).to eq(output_path)
          expect(radiko).to have_received(:system).with(
            "yt-dlp",
            "--no-cache-dir",
            "-o", output_template,
            url,
            exception: true,
          ).ordered
        end
      end

      context "when credentials are specified" do
        let(:email) { "test@radicaster.test" }
        let(:password) { "password" }
        subject(:radiko) { Radigo.new(workdir, email, password) }
        it "executes yt-dlp with credentials" do
          allow(radiko).to receive(:system)
          allow(Dir).to receive(:glob).with("/tmp/20201122010000-TEST.*").and_return([output_path])
          allow(File).to receive(:unlink).with(output_path)
          allow(File).to receive(:exist?).with(output_path).and_return(true)

          ret = radiko.rec(area, id, start_time)

          expect(ret).to eq(output_path)
          expect(radiko).to have_received(:system).with(
            "yt-dlp",
            "--no-cache-dir",
            "-o", output_template,
            "-u", email,
            "-p", password,
            url,
            exception: true,
          ).ordered
        end
      end
    end
  end
end
