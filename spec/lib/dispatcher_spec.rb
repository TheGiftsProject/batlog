require 'spec_helper'

module Log
  describe Dispatcher do
    class Logger1
      def self.meta_data
        { :some => "Hash" }
      end

      def self.log(severity, message, context_data, events, metadata)
        meta_data
      end
    end

    class Logger2
      def self.log(severity, message, context_data, events, metadata)
      end
    end

    class BadLogger
      def self.error_message
        "Bad logger is bad"
      end

      def self.log(severity, message, context_data, events, metadata)
        raise error_message
      end
    end

    describe "dispatch" do

      before do
        Log.config.loggers = [Logger1, Logger2]
      end

      let (:severity) { :error }
      let (:message) { "test message" }
      let (:context_data) { { :a => 2 } }
      let (:events) { [{ :name => "bla", :data => { :b => 3 } }] }

      def dispatch
        Dispatcher.dispatch(severity, message, context_data, events)
      end

      it "calls each logger's log method in order" do
        Logger1.should_receive(:log).ordered
        Logger2.should_receive(:log).ordered
        dispatch
      end

      it "passes the severity to the logger" do
        Logger1.should_receive(:log).with(severity, anything, anything, anything, anything)
        dispatch
      end

      it "passes the message to the logger" do
        Logger1.should_receive(:log).with(anything, message, anything, anything, anything)
        dispatch
      end

      it "passes the context to the logger" do
        Logger1.should_receive(:log).with(anything, anything, context_data, anything, anything)
        dispatch
      end

      it "passes the events to the logger" do
        Logger1.should_receive(:log).with(anything, anything, anything, events, anything)
        dispatch
      end

      it "passes the metadata returned from previous loggers" do
        Logger2.should_receive(:log).with(anything, anything, anything, anything, Logger1.meta_data)
        dispatch
      end

      context "when logger failed" do

        before do
          Log.config.loggers << BadLogger
        end

        it "logs an error using the loggers that worked" do
          Logger1.should_receive(:log).twice
          Logger2.should_receive(:log).twice
          BadLogger.should_receive(:log).once.and_raise("log error")
          dispatch
        end

        context "when set to raise error on log failure" do
          before do
            Log.config.raise_on_log_failure = true
          end

          it "raises an error" do
            BadLogger.should_receive(:log).and_raise("log error")
            expect {
              dispatch
            }.to raise_error
          end
        end
      end
    end
  end

end
