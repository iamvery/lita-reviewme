require 'octokit'

module Lita
  module Handlers
    class Reviewme < Handler
      REDIS_LIST = "reviewers"

      route(
        /add (.+) to reviews/i,
        :add_reviewer,
        command: true,
      )

      route(
        /add reviewer (.+)/i,
        :add_reviewer,
        command: true,
        help: { "add reviewer @iamvery" => "adds @iamvery to the reviewer rotation" },
      )

      route(
        /remove (.+) from reviews/i,
        :remove_reviewer,
        command: true,
      )

      route(
        /remove reviewer (.+)/i,
        :remove_reviewer,
        command: true,
        help: { "remove reviewer @iamvery" => "removes @iamvery from the reviewer rotation" },
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
        %r{review <?(?<url>(https://)?github.com/(?<repo>.+)/(pull|issues)/(?<id>\d+))>?}i,
        :comment_on_github,
        command: true,
        help: { "review https://github.com/user/repo/pull/123" => "adds comment to GH issue requesting review" },
      )

      route(
        %r{review <?(https?://(?!github.com).*)>?}i,
        :mention_reviewer,
        command: true,
        help: { "review http://some-non-github-url.com" => "requests review of the given URL in chat" }
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
        repo = response.match_data[:repo]
        id = response.match_data[:id]
        reviewer = next_reviewer
        comment = github_comment(reviewer)

        begin
          github_client.add_comment(repo, id, comment)
          response.reply("#{reviewer} should be on it...")
        rescue Octokit::Error
          url = response.match_data[:url]
          response.reply("I couldn't post a comment. (Are the permissions right?) #{chat_mention(reviewer, url)}")
        end
      end

      def mention_reviewer(response)
        url = response.matches.flatten.first
        reviewer = next_reviewer
        response.reply(chat_mention(reviewer, url))
      end

      private

      def next_reviewer
        redis.rpoplpush(REDIS_LIST, REDIS_LIST)
      end

      def github_comment(reviewer)
        ":eyes: @#{reviewer}"
      end

      def github_client
        @github_client ||= Octokit::Client.new(access_token: github_access_token)
      end

      def github_access_token
        ENV['GITHUB_WOLFBRAIN_ACCESS_TOKEN']
      end

      def chat_mention(reviewer, url)
        "#{reviewer}: :eyes: #{url}"
      end
    end

    Lita.register_handler(Reviewme)
  end
end
