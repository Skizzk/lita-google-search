require "spec_helper"

describe Lita::Handlers::GoogleSearch, lita_handler: true do
  let(:user) {Lita::User.create("1234", name: "Skizzk")}

  describe "google" do
    it { is_expected.to route_command("google ruby").to(:google_search) }
    it { is_expected.to route_command("google me ruby").to(:google_search) }
    it { is_expected.to route_command("g ruby").to(:google_search) }
    it { is_expected.to route_command("g me ruby").to(:google_search) }

    subject do
      send_command("google test", as: user)
    end

    it "makes a call to google_search gem with the right params" do
      expect(Google::Search::Web).to receive(:new).with(query: "test").and_call_original
      subject
    end

    it "sends back a title, url and a short description" do
      subject
      expect(replies.last(2).first).to match(/^Skizzk: \S+.*http:\/\/.*/)
      expect(replies.last).to match(/\S+/)
    end

    it "answer in private if google me" do
      expect(Google::Search::Web).to receive(:new).with(query: "test").and_call_original
      expect_any_instance_of(Lita::Response).to receive(:reply_privately).twice.and_call_original
      send_command("g me test", as: user)
      expect(replies.last).to match(/\S+/)
    end

    it "should unparse special html char" do
      allow_any_instance_of(Google::Search::Web).to receive(:first).and_return(double("result", title: "lol&#39;d", uri: "", content: "onoes &#39;ll"))
      subject
      expect(replies.last).not_to include("&#39;")
      expect(replies.last).to include("'")
      expect(replies.last(2).first).not_to include("&#39;")
      expect(replies.last(2).first).to include("'")
    end
  end

  describe "image" do
    subject do
      send_command("image test", as: user)
    end

    it { is_expected.to route_command("image ruby").to(:image_search) }
    it { is_expected.to route_command("image me ruby").to(:image_search) }
    it { is_expected.to route_command("img ruby").to(:image_search) }

    it "makes a call to google_search gem with the right params" do
      expect(Google::Search::Image).to receive(:new).with(query: "test").and_call_original
      subject
    end
  end

  describe "youtube" do
    subject do
      send_command("youtube test", as: user)
    end

    it { is_expected.to route_command("youtube ruby").to(:youtube_search) }
    it { is_expected.to route_command("youtube me ruby").to(:youtube_search) }
    it { is_expected.to route_command("yt ruby").to(:youtube_search) }

    it "makes a call to google_search gem with the right params" do
      expect(Google::Search::Video).to receive(:new).with(query: "test").and_call_original
      subject
    end
  end
end
