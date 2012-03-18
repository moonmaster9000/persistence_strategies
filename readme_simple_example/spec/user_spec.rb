require 'ostruct'
require_relative '../abstract_persistence'
require_relative '../twitter_user'

describe Twitter::User do
  let(:user)          { Twitter::User.new }
  let(:tweet)         { OpenStruct.new    }
  let(:tweet_factory) { -> do tweet end   }

  before do
    user.tweet_factory = tweet_factory
  end

  describe "#tweet" do
    it "uses the tweet factory to generate a new tweet" do
      user.tweet("hi").should == tweet
    end

    it "sets the content of the tweet to the desired text" do
      user.tweet("hi").content.should == "hi"
    end

    it "associates the tweet with the user" do
      user.tweet("hi").user.should == user
    end
  end

  describe ".all" do
    it "should default to empty" do
      Twitter::User.all.should be_empty
    end
  end

  describe "#save!" do
    it "should add the user to the list of all users" do
      user.save!
      Twitter::User.all.should include(user)
    end
  end
end
