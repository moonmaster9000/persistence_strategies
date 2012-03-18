module Twitter
  module Persistence
    class User
      def self.all
        @users ||= []
      end

      def save!
        self.class.all << self
      end
    end
  end
end
