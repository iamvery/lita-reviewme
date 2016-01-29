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
        help: { "add reviewer iamvery" => "adds iamvery to the reviewer rotation" },
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
        help: { "remove reviewer iamvery" => "removes iamvery from the reviewer rotation" },
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

      def add_reviewer(response, room: get_room(response))
        reviewer = response.matches.flatten.first
        ns_redis(room.id).lpush(REDIS_LIST, reviewer)
        response.reply("added #{reviewer} to reviews")
      end

      def remove_reviewer(response, room: get_room(response))
        reviewer = response.matches.flatten.first
        ns_redis(room.id).lrem(REDIS_LIST, 0, reviewer)
        response.reply("removed #{reviewer} from reviews")
      end

      def display_reviewers(response, room: get_room(response))
        reviewers = ns_redis(room.id).lrange(REDIS_LIST, 0, -1)
        response.reply("Responding via private message...")
        response.reply_privately("#{room.name}: #{reviewers.join(', ')}")
      end

      def generate_assignment(response, room: get_room(response))
        reviewer = next_reviewer(room)
        response.reply(reviewer.to_s)
      end

      def comment_on_github(response, room: get_room(response))
        repo = response.match_data[:repo]
        id = response.match_data[:id]

        reviewer = next_reviewer(room)
        begin
          pull_request = github_client.pull_request(repo, id)
          owner = pull_request.user.login
          reviewer = next_reviewer(room) if owner == reviewer
        rescue Octokit::Error
          response.reply("Unable to check who issued the pull request. Sorry if you end up being assigned your own PR!")
        end
        comment = github_comment(reviewer)

        begin
          github_client.add_comment(repo, id, comment)
          response.reply("#{reviewer} should be on it...")
        rescue Octokit::Error
          url = response.match_data[:url]
          response.reply("I couldn't post a comment. (Are the permissions right?) #{chat_mention(reviewer, url)}")
        end
      end

      def mention_reviewer(response, room: get_room(response))
        url = response.matches.flatten.first
        reviewer = next_reviewer(room)
        response.reply(chat_mention(reviewer, url))
      end

      private

      def next_reviewer(room)
        ns_redis(room.id).rpoplpush(REDIS_LIST, REDIS_LIST)
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

      def get_room(response)
        room_id = response.message.source.room
        Lita::Room.find_by_id(room_id) || Lita::Room.new(room_id)
      end

      def ns_redis(namespace)
        Redis::Namespace.new(namespace, redis: redis)
      end
    end

    Lita.register_handler(Reviewme)
  end
end
