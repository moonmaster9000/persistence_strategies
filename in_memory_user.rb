require_relative 'twitter'

module InMemory
  class User
    class << self
      def truncate!
        @users = nil
      end

      def find_by_username(username)
        all.detect {|u| u.username == username} || raise
      end

      def all
        @users ||= []
      end
    end

    attr_accessor :username

    def initialize
      self.class.all << self
    end
  end
end

Twitter.persistence = InMemory
