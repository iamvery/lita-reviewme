require 'delegate'

module Lita
  module Reviewme
    class Github
      class UnknownOwner < StandardError; end
      class CannotPostComment < StandardError; end

      extend Forwardable

      attr_reader :config, :repo, :pr_id

      delegate [
        :github_access_token,
        :github_comment_template,
        :github_comment,
        :github_request_review
      ] => :config

      def initialize(config, repo, pr_id)
        @config = config
        @repo = repo
        @pr_id = pr_id
      end

      def owner
        pull_request.user.login
      rescue Octokit::Error
        raise UnknownOwner
      end

      def assign(reviewer)
        request_review(reviewer) if github_request_review
        add_comment(reviewer) if github_comment

        raise CannotPostComment if !github_request_review && !github_comment
      rescue Octokit::Error => e
        raise CannotPostComment
      end

      private

      def client
        @client ||= Octokit::Client.new(access_token: github_access_token)
      end

      def pull_request
        @pull_request ||= client.pull_request(repo, pr_id)
      end

      def request_review(reviewer)
        options = { accept: 'application/vnd.github.black-cat-preview' }

        client.request_pull_request_review(repo, pr_id, [reviewer], options)
      end

      def add_comment(reviewer)
        client.add_comment(repo, pr_id, comment(reviewer))
      end

      def comment(reviewer)
        if github_comment_template.respond_to?(:call)
          github_comment_template.call(reviewer, pull_request)
        else
          github_comment_template % { reviewer: "@#{reviewer}" }
        end
      end
    end
  end
end
