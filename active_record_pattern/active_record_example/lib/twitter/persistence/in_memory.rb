module Twitter
  module Persistence
    class RecordNotFound < StandardError; end

    class User
      def self.truncate!
        @users = nil
      end

      def self.find_by_username(username)
        all.detect {|u| u.username == username} || raise(RecordNotFound)
      end

      def self.all
        @users ||= []
      end

      attr_accessor :username

      def save!
        self.class.all << self
      end
    end
  end
end
