module Twitter
  class User
    attr_writer :tweet_factory
    attr_accessor :name, :username

    def==(user)
      self.username == user.username
    end

    def initialize(name, username)
      @name = name
      @username = username
    end

    def tweet(content)
      @tweet_factory.call.tap do |t|
        t.content = content
        t.user = self
      end
    end
  end
end
