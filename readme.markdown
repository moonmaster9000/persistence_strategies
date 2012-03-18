# Decoupling Persistence from your Domain

In this README, I'll show you two simple ways to isolate your business
logic from your persistence concerns. The first example uses inheritance
and a naming convention; the second, mixins.

However, I want you to walk through a refactoring to understand it. In
general, I don't recommend starting with a pattern unless you know it _so
well_ that refactoring into it would feel like a truly needless exercise.

Note: Checkout the
[readme\_simple\_example](https://github.com/moonmaster9000/persistence_strategies/tree/master/readme_simple_example) directory for a working example of the code in this README. Or, checkout the [active\_record\_example](https://github.com/moonmaster9000/persistence_strategies/tree/master/active_record_example) directory for a larger example with both an in-memory persistence plugin _and_ an ActiveRecord persistence plugin. (Caveat: I've only tested this code on MRI 1.9.3-p125).

## Twitter

Let's develop twitter. OK, not really, but let's start with the
following rspec spec:

```ruby
require 'ostruct'
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
  end
end
```

Basically, we've written a spec that says a "user" should be able to
tweet. Since that's the single most essential feature of the Twitter application, I thought it would makes sense to start with that. If we can't get this abstraction right, then we're doomed.

The "tweet\_factory" bit may seem a little odd. 
Essentially, we don't want to tightly couple our User
model to a Tweet model; instead, we'd simply like to inject a method for
creating tweets into it at runtime. This makes it simpler to test, and
makes our User model simpler to maintain. (If you'd like to learn more
about this sort of dependency injection, I _highly_ recommend purchasing
Avdi's ebook ["Objects on Rails"](http://objectsonrails.com)).

Run the spec, watch it fail, then write some code until it passes. You
might end up with something like this:

```ruby
module Twitter
  class User
    attr_writer :tweet_factory

    def tweet(content)
      @tweet_factory.call
    end
  end
end
```

Great! There's likely a couple other features of our tweet method that
we'll want to go ahead and add:

```ruby
#...
it "sets the content of the tweet to the desired text" do
  user.tweet("hi").content.should == "hi"
end

it "associates the tweet with the user" do
  user.tweet("hi").user.should == user
end
```

Simple enough. Let's get these tests passing:

```ruby
module Twitter
  class User
    attr_writer :tweet_factory

    def tweet(content)
      @tweet_factory.call.tap do |t|
        t.content = content
        t.user    = self
      end
    end
  end
end
```

We're done! We've just implemented twitter! Oh wait, what about
persistence?


## Saving users

Clearly, before we can launch our app into the real world, we're going
to need to persist our objects and retrieve them in various ways. Let's
start by simply adding specs for saving users, and for finding all
users.

```ruby
describe Twitter::User do
  #...

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
```

Seems simple enough. Let's update our user class and make these specs
pass:

```ruby
module Twitter
  class User
    def self.all
      @users ||= []
    end

    attr_writer :tweet_factory

    def tweet(content)
      @tweet_factory.call.tap do |t|
        t.content = content
        t.user    = self
      end
    end

    def save!
      self.class.all << self
    end
  end
end
```

Great! There are, of course, flaws in our implementation. For starters,
it's not really even a persistence layer. These objects will die the
second our script exits, never to return. Also, there's a bug.
Calling "#save!" multiple times will persist duplicate objects into
".all". And if we build any more persistence
specs, we will absolutely need a "User.truncate!" method  that destroys
all the users (we'll want to run that before every test to ensure
isolation between tests).

To make this article short, however, let's ignore those problems
and move on to some refactoring. 

## Refactoring out persistence

We have a problem. Originally, we started out our User spec by
describing what a User actually does on Twitter (they tweet!). But now
we've muddied up our domain with the concerns of our persistence layer.

Is that really such a big deal? Maybe not. I mean, if you're cool with
creating inflexible, tightly coupled systems, then carry on.

There's all kinds of different ways to solve this problem. There's the
"Rails Way" - pretend it's not a problem ;-).  There's the data mapper
pattern (described notably in Martin Fowler's "Patterns of Enterprise
Application Architecture"). There's the Active Record pattern (of which the powerful ActiveRecord library is an implementation of). There's Avdi Grim's "fig leaf" approach described in his "Objects on Rails" book. There's Piotor Solnic's approach that has you pass in persistent objects into domain models. And I'm sure many, many more that I'm not aware of.

Let's start by refactoring out the persistence into a seperate class:

```ruby
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

module Twitter
  class User < Twitter::Persistence::User
    attr_writer :tweet_factory

    def tweet(content)
      @tweet_factory.call.tap do |t|
        t.content = content
        t.user    = self
      end
    end
  end
end
```

Now run the tests again. They should still all pass.

Next, move the `Twitter::Persistence::User` class into it's own file. I
called mine "in\_memory\_persistence.rb" - since what we've written is
actually a simple in memory persistence solution. 

We can also move the persistence specs into their own spec file:

```ruby
require_relative '../in_memory_persistence'

User = Twitter::Persistence::User

describe User do
  describe ".all" do
    it "should default to empty" do
      User.all.should be_empty
    end
  end

  describe "#save!" do
    it "should add the user to the list of all users" do
      user = User.new
      user.save!
      User.all.should include(user)
    end
  end
end
```

Now we simply need an abstract persistence layer standin to unit test
our business logic. Create another file called
"abstract\_persistence\_layer.rb" and place the following code:

```ruby
module Twitter
  module Persistence
    class User; end
  end
end
```

Now you can require this file at the top of your user spec to get those
tests to pass again.

## Wins

In a way, we've isolated our persistence layer from our business logic.
We can test them completely independently of each other. When we look at
our domain models in this application, they should scream "TWITTER", not "DATABASE".

You may have noticed, but we've also written an integration test suite
for our persistence layer. If we wanted to replace our in-memory
persistence layer with a file-system persistence layer, or a database
persistence layer, we could test it by simply replacing the
`require_relative '../in_memory_persistence'` in our persistence spec 
with `require_relative '../file_persistence'` or 
`require_relative '../database_persistence'`. That seems like a nice win.

In reality, you won't likely be replacing your persistence layer a lot.
However, a nice side effect of this sort of de-coupling is that it makes it possible to parallelize the work on
our project. We could have one team develop the persistence layer while
another develops the domain models. Other teams could work on various
delivery mechanisms (e.g., a website, a REST api, an smartphone app, etc.)
by requiring both the business logic layer and a persistence layer.

Note that we could have used mixins instead of inheritance to seperate
our persistence layer. In fact, I'd prefer that. We could remove the
inheritance from our domain model completely, and simply let the
persistence layer inject modules into our domain models for supporting
the persistence concerns:

```ruby
#user.rb
module Twitter
  class User
    def tweet(content)
      #...
    end
  end
end


#in_memory_persistence.rb
require_relative 'user'
module Twitter
  module Persistence
    module User
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def all
          #...
        end
      end

      def save!
        #...
      end
    end
  end
end

Twitter::User.send :include, Twitter::Persistence::User
```

Now we no longer need to define an abstract persistence layer standin
for testing our user domain model. The only problem with this approach is that it would likely make working with ORMs like
ActiveRecord tricky, since they assume that they're bolted on to your
models with inheritance.
