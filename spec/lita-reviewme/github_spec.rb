require "spec_helper"

describe Lita::Reviewme::Github do
  let(:repo) { "gh_user/repo" }
  let(:id) { "123" }
  let(:user) { OpenStruct.new(login: 'iamvery') }
  let(:title) { 'PR Title' }
  let(:pull_request) { OpenStruct.new(user: user, title: title) }
  let(:github_comment_template) { ":eyes: %{reviewer}" }
  let(:github_comment) { true }
  let(:github_request_review) { false }

  let(:config) do
    OpenStruct.new(
      github_access_token: 'access-token',
      github_comment_template: github_comment_template,
      github_comment: github_comment,
      github_request_review: github_request_review
    )
  end

  before do
    allow_any_instance_of(Octokit::Client).to receive(:pull_request)
      .and_return(pull_request)
  end

  subject { described_class.new(config, repo, id) }

  describe "ownership" do
    it "comes from the pull request" do
      expect(subject.owner).to eq('iamvery')
    end

    describe "unexpected error" do
      class User; def login; raise Octokit::Error; end; end

      let(:user) { User.new }

      it "raises an exception" do
        expect { subject.owner }.to raise_error(Lita::Reviewme::Github::UnknownOwner)
      end
    end
  end

  describe "assignment" do
    describe "via review request" do
      let(:github_comment) { false }
      let(:github_request_review) { true }

      it "uses the request review api" do
        expect_any_instance_of(Octokit::Client).to receive(:request_pull_request_review)
          .with(repo, id, ['iamvery'], { accept: "application/vnd.github.black-cat-preview" })

        subject.assign('iamvery')
      end
    end

    describe "via comment api" do
      describe "with a string" do
        it "evaluates template" do
          expect_any_instance_of(Octokit::Client).to receive(:add_comment)
            .with(repo, id, ":eyes: @iamvery")

          subject.assign('iamvery')
        end
      end

      describe "with a proc" do
        let(:github_comment_template) do
          lambda do |reviewer, pull_request|
            "hey @#{reviewer}, this is from a lambda! :tada: #{title}"
          end
        end

        it "executes a proc if specified in `config.github_comment_template`" do
          expected_msg = "hey @iamvery, this is from a lambda! :tada: #{title}"

          expect_any_instance_of(Octokit::Client).to receive(:add_comment)
            .with(repo, id, expected_msg)

          subject.assign('iamvery')
        end
      end
    end
  end
end

