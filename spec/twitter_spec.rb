require_relative '../twitter'
require 'ostruct'

describe Twitter::User do
  let(:user)          { Twitter::User.new           }
  let(:tweet_factory) { -> do tweet end             }
  let(:tweet)         { OpenStruct.new              }

  before do
    user.tweet_factory = tweet_factory
  end

  describe "#tweet" do
    it "uses the tweet generator factory to generate a new tweet" do
      tweet_factory.should_receive(:call).and_return tweet
      user.tweet("hi")
    end

    it "sets the content of the tweet to the desired text" do
      user.tweet("hi").content.should == "hi"
    end

    it "associates the tweet with the user" do
      user.tweet("hi").user.should == user
    end
  end
end
