module Lita
  module Handlers
    class Reviewme < Handler
      REDIS_LIST = "reviewers"

      route(/add (.+) to reviews/i, :add_reviewer, command: true, help: { "add @iamvery to reviews" => "adds @iamvery to the reviewer rotation" })
      route(/remove (.+) from reviews/i, :remove_reviewer, command: true, help: { "remove @iamvery from reviews" => "removes @iamvery from the reviewer rotation" })

      def add_reviewer(response)
        reviewer = response.matches.flatten.first
        redis.rpush(REDIS_LIST, reviewer)
        response.reply("added #{reviewer} to reviews")
      end

      def remove_reviewer(response)
        reviewer = response.matches.flatten.first
        redis.lrem(REDIS_LIST, 0, reviewer)
        response.reply("removed #{reviewer} from reviews")
      end
    end

    Lita.register_handler(Reviewme)
  end
end
