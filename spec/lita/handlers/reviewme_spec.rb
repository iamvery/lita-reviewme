require "spec_helper"

describe Lita::Handlers::Reviewme, lita_handler: true do
  it { routes_command("add @iamvery to reviews").to :add_reviewer }
  it { routes_command("remove @iamvery from reviews").to :remove_reviewer }
  it { routes_command("review me").to :generate_assignment }
  it { routes_command("review https://github.com/user/repo/pull/123").to :comment_on_github }
  it { routes_command("review https://github.com/user/repo/issues/123").to :comment_on_github }

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
      expect(replies.last).to eq("@iamvery")

      send_command("review me")
      expect(replies.last).to eq("@zacstewart")
    end
  end

  describe "#comment_on_github" do
    it "posts comment on github" do
      repo = "gh_user/repo"
      id = "123"

      expect_any_instance_of(Octokit::Client).to receive(:add_comment)
        .with(repo, id, ":eyes: @iamvery")

      send_command("add @iamvery to reviews")
      send_command("review https://github.com/#{repo}/pull/#{id}")

      expect(replies.last).to eq("@iamvery should be on it...")
    end
  end
end
