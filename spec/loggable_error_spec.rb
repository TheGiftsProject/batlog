describe Log::LoggableError do
  subject { Log::LoggableError }

  let (:test_message) { "test message" }
  let (:test_data) { { a: 2 } }

  it "contains the error data" do
    error = subject.new(test_message, test_data)
    error.data.should == test_data
  end
end
