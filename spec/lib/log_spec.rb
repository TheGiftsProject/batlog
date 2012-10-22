require 'spec_helper'

describe Log do
  subject { Log }

  let(:severity) { :error }
  let(:test_message) { "Test message" }
  let(:test_context) { { :foo => 2, :bar => "hello" } }

  let(:event_name) { "Event name" }
  let(:event_data) { { :ev_data => 5 } }

  let(:error_context) { { :error => 10 } }
  let(:error_message) { Log::LoggableError.new("Loggable Error Message", error_context) }

  before(:each) do
    subject.clear_events
  end

  describe "basics" do

    before do
      Log.config.loggers = [ Log::TestLogger ]
      Log::TestLogger.reset
    end

    it "should be able to write a message without a context" do
      Log.info("test")
      Log::TestLogger.logs.count.should == 1
    end

    it "should be able to write a message with a context" do
      Log.info("test", :a => 1)
      Log::TestLogger.logs.count.should == 1
    end

    it "should be able to write a message with a context and an event" do
      Log.info("test", {:a => 1}, [{:name => 1, :data => 2}])
      Log::TestLogger.logs.count.should == 1
    end

  end

  describe "log.writes" do


    shared_examples_for "log severity" do |severity|
      context "when message is a LoggableError" do
        it "adds the log data to the context" do
          new_context = subject.send(:handle_loggable_error, error_message, test_context)
          new_context.should == test_context.merge(:error_data => error_context)
        end

        it "adds the error's data to the context" do
          Log::Dispatcher.should_receive(:dispatch).with(severity, error_message, test_context.merge(:error_data => error_context), Log::Events.all)
          subject.send(severity, error_message, test_context)
        end
      end

      it "dispatches the log data to the loggers" do
        Log::Dispatcher.should_receive(:dispatch).with(severity, test_message, test_context, Log::Events.all)
        subject.send(severity, test_message, test_context)
      end
    end

    Log::SEVERITIES.each_key do |severity|
      describe severity do
        it_behaves_like "log severity", severity
      end
    end
  end

  describe "log.asserts" do

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
          subject.stub(:assert_failed)
          subject.assert(false, test_message, test_context).should == false
        end
      end
    end

    describe "assert_failed" do

      before do
        Log.config.raise_on_log_failure = false
      end

      it "writes to log" do
        subject.should_receive(:write).with(severity, test_message, test_context)
        subject.send(:assert_failed, severity, test_message, test_context, false)
      end

      def should_raise_an_error(raise_error_flag)
        expect {
            subject.send(:assert_failed, severity, test_message, test_context, raise_error_flag)
          }.to raise_error(Log::LoggableError)
      end

      def should_not_raise_an_error(raise_error_flag)
          expect {
              subject.send(:assert_failed, severity, test_message, test_context, raise_error_flag)
            }.not_to raise_error
      end

      context "config is false" do

        before do
          subject.config.raise_on_failed_asserts = false
        end

        it "should raise error when flag is true" do
            should_raise_an_error(true)
        end

        it "should not raise error when flag is nil" do
            should_not_raise_an_error(nil)
        end

        it "should not raise error when flag is false" do
            should_not_raise_an_error(false)
        end
      end

      context "config is true" do

        before do
          subject.config.raise_on_failed_asserts = true
        end

        it "should raise error when flag is true" do
            should_raise_an_error(true)
        end

        it "should raise error when flag is nil" do
            should_raise_an_error(nil)
        end

        it "should not raise error when flag is false" do
            should_not_raise_an_error(false)
        end

      end
    end
  end

  describe "write events" do
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
  end

end
