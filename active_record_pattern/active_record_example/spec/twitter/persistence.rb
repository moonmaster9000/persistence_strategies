PERSISTENCE_SPEC = ->(user_model) {
  describe user_model do
    before do
      user_model.truncate!
    end

    describe ".truncate!" do
      before do
        user_model.new.save!
      end

      it "should delete all stored users" do
        user_model.truncate!
        user_model.all.should be_empty
      end
    end

    describe ".save!" do
      it "should add the new user to the list of all users" do
        user = user_model.new
        user.save!
        user_model.all.should include(user)
      end
    end

    describe ".find_by_username" do
      before do
        @user = user_model.new
        @user.username = "foo"
        @user.save!
      end

      it "should return a user if it finds one with a matching name" do
        user_model.find_by_username("foo").should == @user
      end

      it "should throw an exception otherwise" do
        -> {user_model.find_by_username("oops")}.should raise_exception(Twitter::Persistence::RecordNotFound)
      end
    end
  end
}
