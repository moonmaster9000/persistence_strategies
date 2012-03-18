module Twitter
  class User < Twitter::Persistence::User
    attr_writer :tweet_factory

    def tweet(content)
      @tweet_factory.call.tap do |t|
        t.content = content
        t.user    = self
      end
    end
  end
end
