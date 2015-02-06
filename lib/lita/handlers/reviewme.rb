require 'octokit'

module Lita
  module Handlers
    class Reviewme < Handler
      REDIS_LIST = "reviewers"

      route(
        /add (.+) to reviews/i,
        :add_reviewer,
        command: true,
        help: { "add @iamvery to reviews" => "adds @iamvery to the reviewer rotation" },
      )

      route(
        /remove (.+) from reviews/i,
        :remove_reviewer,
        command: true,
        help: { "remove @iamvery from reviews" => "removes @iamvery from the reviewer rotation" },
      )

      route(
        /reviewers/i,
        :display_reviewers,
        command: true,
        help: { "reviewers" => "display list of reviewers" },
      )

      route(
        /review me/i,
        :generate_assignment,
        command: true,
        help: { "review me" => "responds with the next reviewer" },
      )

      route(
        %r{review (https://)?github.com/(?<repo>.+)/(pull|issues)/(?<id>\d+)}i,
        :comment_on_github,
        command: true,
      )

      def add_reviewer(response)
        reviewer = response.matches.flatten.first
        redis.lpush(REDIS_LIST, reviewer)
        response.reply("added #{reviewer} to reviews")
      end

      def remove_reviewer(response)
        reviewer = response.matches.flatten.first
        redis.lrem(REDIS_LIST, 0, reviewer)
        response.reply("removed #{reviewer} from reviews")
      end

      def display_reviewers(response)
        reviewers = redis.lrange(REDIS_LIST, 0, -1)
        response.reply(reviewers.join(', '))
      end

      def generate_assignment(response)
        reviewer = next_reviewer
        response.reply(reviewer.to_s)
      end

      def comment_on_github(response)
        repo = response.matches.flatten.first
        id = response.matches.flatten.last
        reviewer = next_reviewer
        comment = github_comment(reviewer)

        github_client.add_comment(repo, id, comment)
        response.reply("#{reviewer} should be on it...")
      end

      private

      def next_reviewer
        redis.rpoplpush(REDIS_LIST, REDIS_LIST)
      end

      def github_comment(reviewer)
        ":eyes: #{reviewer}"
      end

      def github_client
        @github_client ||= Octokit::Client.new(access_token: github_access_token)
      end

      def github_access_token
        ENV['GITHUB_WOLFBRAIN_ACCESS_TOKEN']
      end
    end

    Lita.register_handler(Reviewme)
  end
end
