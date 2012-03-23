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
