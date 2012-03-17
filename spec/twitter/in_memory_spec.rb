require 'spec_helper'
require 'twitter/persistence/in_memory'

User = Twitter::Persistence::User

describe User do
  before do
    User.truncate!
  end

  describe ".truncate!" do
    before do
      User.new.save!
    end

    it "should delete all stored users" do
      User.truncate!
      User.all.should be_empty
    end
  end

  describe ".save!" do
    it "should add the new user to the list of all users" do
      user = User.new
      user.save!
      User.all.should include(user)
    end
  end

  describe ".find_by_username" do
    it "should return a user if it finds one with a matching name" do
      u = User.new
      u.username = "foo"
      u.save!
      User.find_by_username("foo").should == u
    end

    it "should throw a Twitter::Persistence::RecordNotFound exception otherwise" do
      expect { 
        User.find_by_username("oops") 
      }.to(
        raise_exception(Twitter::Persistence::RecordNotFound)
      )
    end
  end
end
