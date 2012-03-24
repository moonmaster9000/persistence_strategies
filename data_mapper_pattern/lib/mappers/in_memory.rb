module Twitter
  module Mappers
    class RecordNotFound < StandardError; end

    module User
      extend self

      def truncate!
        @users = nil
      end

      def find_by_username!(username)
        find_by_username(username) || raise(Twitter::Mappers::RecordNotFound)
      end

      def all
        @users ||= []
      end

      def persist!(user)
        all.delete(user)
        all << user
      end

      private
      def find_by_username(username)
        all.detect {|u| u.username == username} 
      end
    end
  end
end
