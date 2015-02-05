require "spec_helper"

describe Lita::Handlers::Reviewme, lita_handler: true do
  it { routes_command("add @iamvery to reviews").to :add_reviewer }
  it { routes_command("remove @iamvery from reviews").to :remove_reviewer }

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
end
