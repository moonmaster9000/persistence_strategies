PERSISTENCE_SPEC = -> do
  describe Twitter::Mappers::User do
    before do
      described_class.truncate!
    end

    describe ".all" do
      it "should default to an empty list" do
        described_class.all.should be_empty
      end
    end
    
    describe ".find_by_username!" do
      it "should raise an exception if no user is found" do
        expect { described_class.find_by_username!("foo") }.to raise_exception(Twitter::Mappers::RecordNotFound)
      end

      it "should return the user if the user has been persisted" do
        user = Twitter::User.new "foo bar", "foo"
        described_class.persist! user
        described_class.find_by_username!("foo").should == user
      end
    end

    describe "#persist!" do
      it "should add a user to .all if the user has never been persisted" do
        user = Twitter::User.new "foo bar", "foo"
        described_class.persist! user
        described_class.all.should include(user)
      end

      it "should update a user in .all if the user has already been persisted" do
        user = OpenStruct.new name: "Foo Bar", username: "foobar"
        described_class.persist! user
        user.name = "Foo YAR"
        described_class.persist! user
        described_class.find_by_username!("foobar").name.should == "Foo YAR"
      end
    end

    describe "#truncate!" do
      it "should delete all users" do
        user = OpenStruct.new name: "foo", username: "foobar"
        described_class.persist! user
        described_class.truncate!
        described_class.all.should be_empty
      end
    end
  end
end
