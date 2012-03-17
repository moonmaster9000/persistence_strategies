module AbstractPersistenceLayer
  class User; end
end

module Twitter
  extend self
  attr_writer :persistence

  def persistence
    @persistence ||= AbstractPersistenceLayer
  end
end

module Twitter
  class User < Twitter.persistence::User
    attr_writer :tweet_factory

    def tweet(content)
      @tweet_factory.call.tap do |t|
        t.content = content
        t.user    = self
      end
    end
  end
end
