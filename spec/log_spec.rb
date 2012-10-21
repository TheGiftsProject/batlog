require 'lib/log'

describe Log do
  subject { Log }

  let(:severity) { :error }
  let(:test_message) { "Test message" }
  let(:test_context) { { :foo => 2, :bar => "hello" } }

  let(:event_name) { "Event name" }
  let(:event_data) { { :ev_data => 5 } }

  let(:error_context) { { :error => 10 } }
  let(:error_message) { Log::LoggableError.new(test_message, error_context) }

  before(:each) do
    subject.send(:dispatcher).stub(:dispatch)
    subject.raise_on_failed_asserts(false)
    subject.raise_on_log_failure(false)
    subject.clear_events
  end

  describe "assert" do
    context "when condition is true" do
      it "returns true" do
        subject.assert(true, test_message, test_context).should == true
      end

      it "doesn't fail" do
        subject.should_not_receive(:assert_failed)
        subject.assert(true, test_message, test_context)
      end
    end

    context "when condition is false" do
      it "fails" do
        subject.should_receive(:assert_failed)
        subject.assert(false, test_message, test_context)
      end

      it "returns false" do
        subject.assert(false, test_message, test_context).should == false
      end
    end
  end

  describe "assert_failed" do
    shared_examples_for "raise error on assert failure" do |raise_error|
      it "raises an error" do
        expect {
          subject.send(:assert_failed, severity, test_message, test_context, raise_error)
        }.to raise_error(Log::LoggableError)
      end
    end

    it "writes to log" do
      subject.should_receive(:write).with(severity, test_message, test_context)
      subject.send(:assert_failed, severity, test_message, test_context, false)
    end

    context "when raise_error is false" do
      it "doesn't raise an error" do
        expect {
          subject.send(:assert_failed, severity, test_message, test_context, false)
        }.not_to raise_error
      end
    end

    context "when raise_error is true" do
      it_behaves_like "raise error on assert failure", true
    end

    context "when Log's raise_on_failed_asserts is true" do
      before(:each) do
        subject.raise_on_failed_asserts(true)
      end

      it_behaves_like "raise error on assert failure", false
    end
  end

  describe "event" do
    it "adds an event to the events array" do
      Log::Events.should_receive(:add).with(event_name, event_data)
      subject.event(event_name, event_data)
    end
  end

  describe "clear_events" do
    it "resets the events array" do
      Log::Events.should_receive(:reset)
      subject.clear_events
    end
  end

  shared_examples_for "log severity" do |severity|
    context "when message is a LoggableError" do
      it "adds the error's data to the context" do
        new_context = subject.send(:handle_loggable_error, error_message, test_context)
        new_context.should == test_context.merge({ :error_data => error_context })

        subject.should_receive(:handle_loggable_error).with(error_message, test_context)
        subject.send(severity, error_message, test_context)
      end
    end

    it "dispatches the log data to the loggers" do
      subject.send(:dispatcher).should_receive(:dispatch).with(severity, test_message, test_context, Log::Events.all)
      subject.send(severity, test_message, test_context)
    end
  end

  Log::SEVERITIES.each_key do |severity|
    it_behaves_like "log severity", severity
  end
end
