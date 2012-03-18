require 'active_record'

module Twitter
  module Persistence
    class RecordNotFound < StandardError; end

    class User < ActiveRecord::Base
      class << self
        def truncate!
          delete_all
        end

        def find_by_username(n)
          super || raise(Twitter::Persistence::RecordNotFound)
        end
      end
    end
  end
end
