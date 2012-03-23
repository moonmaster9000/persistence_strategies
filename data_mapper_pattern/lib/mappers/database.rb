require 'active_record'
require_relative '../domain/user'

module Twitter
  module Mappers
    RecordNotFound = Class.new(StandardError)

    module User
      extend self

      def truncate!
        UserMetadata.delete_all
      end

      def find_by_username!(username)
        find_by_username(username) || raise(RecordNotFound)
      end

      def all
        UserMetadata.all.map {|um| wrap_metadata(um) }
      end

      def persist!(user)
        UserMetadata.find_or_create_by_username(user.username).tap do |u|
          u.name = user.name
          u.save!
        end
      end

      private
      def find_by_username(username)
        metadata = find_metadata_by_username(username)
        wrap_metadata(metadata) if metadata
      end

      def wrap_metadata(metadata)
        Twitter::User.new(metadata.name, metadata.username)
      end

      def find_metadata_by_username(username)
        UserMetadata.find_by_username(username)
      end
    end

    class UserMetadata < ActiveRecord::Base
    end
  end
end
