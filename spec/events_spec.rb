describe Log::Events do
  let(:test_name) { "Test name" }
  let(:test_data) { { a: 5 } }

  it "adds new event to the events array" do
    subject.add(test_name, test_data)
    subject.all.last.should == { name: test_name, data: test_data }
  end

  it "clears the events array" do
    subject.add(test_name, test_data)
    subject.reset
    subject.all.should == []
  end

  it "returns the whole events array" do
    subject.add(test_name, test_data)
    subject.add(test_name, test_data)
    subject.add(test_name, test_data)
    subject.all.count.should == 3
  end
end
