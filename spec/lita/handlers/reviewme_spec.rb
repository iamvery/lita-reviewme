require "spec_helper"

describe Lita::Handlers::Reviewme, lita_handler: true do
  it { routes_command("add @iamvery to reviews").to :add_reviewer }
  it { routes_command("remove @iamvery from reviews").to :remove_reviewer }
  it { routes_command("review me").to :generate_assignment }

  let(:reply) { replies.last }

  describe "#add_reviewer" do
    it "adds a name to the list" do
      send_command("add @iamvery to reviews")

      expect(reply).to eq("added @iamvery to reviews")
    end
  end

  describe "#remove_reviewer" do
    it "removes a name from the list" do
      send_command("remove @iamvery from reviews")

      expect(reply).to eq("removed @iamvery from reviews")
    end
  end

  describe "#generate_assignment" do
    it "responds with the next reviewer's name" do
      send_command("add @iamvery to reviews")
      send_command("review me")

      expect(reply).to eq("@iamvery")
    end

    it "rotates the response each time" do
      send_command("add @iamvery to reviews")
      send_command("add @zacstewart to reviews")

      send_command("review me")
      expect(replies.last).to eq("@zacstewart")

      send_command("review me")
      expect(replies.last).to eq("@iamvery")
    end
  end
end
