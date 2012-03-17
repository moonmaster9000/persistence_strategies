require_relative '../in_memory_user'

describe InMemory::User do
  before do
    InMemory::User.truncate!
  end

  describe ".truncate!" do
    before do
      InMemory::User.new
    end

    it "should delete all stored users" do
      InMemory::User.truncate!
      InMemory::User.all.should be_empty
    end
  end

  describe ".new" do
    it "should add the new user to the list of all users" do
      user = InMemory::User.new
      InMemory::User.all.should include(user)
    end
  end

  describe ".find_by_username" do
    it "should return a user if it finds one with a matching name" do
      u = InMemory::User.new
      u.username = "foo"
      InMemory::User.find_by_username("foo").should == u
    end

    it "should throw an exception otherwise" do
      expect { InMemory::User.find_by_username("oops") }.to raise_exception
    end
  end
end
