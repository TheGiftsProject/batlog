# BatLog v0.9 [![Build Status](https://secure.travis-ci.org/TheGiftsProject/batlog.png)](http://travis-ci.org/TheGiftsProject/batlog)
![batlog-logo](https://dl.dropbox.com/u/7525692/batlog-withtext.png "BatLog")

## Setup
To install BatLog into your Rails app just the gem to your Gemfile
```ruby
gem 'batlog'
```
After that run `rails generate db_log` to create the db_log's table migration.
By default BatLog writes to three places - the database, the rails logger and exceptions to exceptional
You can overide this behaivour by providing your own loggers or changing the default logger in the configuration.

The cool thing about BatLog is that it adds the concept of `context` - your logs aren't one time message left by a deity but
 are part of a flow of a user in specific system and circumstance. BatLog lets you collect a context for the current Thread
 and dump it as part of the BatLog whenever needed be it in Exception and be it in debug prints.

## Usage
### Logging
```ruby
Log.debug(message, context)
Log.info(message, context)
Log.warn(message, context)
Log.error(message, context)
Log.fatal(message, context)
```
Use these to record logs. The method indicates the severity.
* `message` - The message to record to log. Can be of the following types:
  * `String` - Will be used as-is.
  * `Exception` - Message will be extracted from exception.
  * `Log::LoggableError` - Message will be extracted from exception and data will be merged into context
* `context` - `Hash`. Extra data that's related to the message.

### Events
Events are kept in memory (until clear_events is called or the thread exits) and 
are only written when one of the above log methods is called.

```ruby
Log.event(name, data)
```
Adds an event to `Log`'s internal event array.
* `name` - `String`. The name of the event.
* `data` - `Hash`. Extra data that's related to the event.

```ruby
Log.clear_events
```
Empties the list of events.

### Asserts
```ruby
Log.assert(condition, message, context, options)
```
* `condition` - `Boolean`. Indicates whether the condition you were testing succeeded. When `false` - triggers a log.
* `message` - Same as in the logging methods.
* `context` - Same as in the logging methods.
* `options` - `Hash`. Includes the following:
  * `severity` - `Symbol`. The severity to use for logging when the condition fails. (Default: `:error`)
  * `raise_error` - `Boolean`. Indicates whether the assert should raise an error if condition fails. (Default: `false`)

### Configuring `Log`
To configure Log just create an initializer `config/initializers/log.rb`
There you can set the configuration of the log system.
```ruby
Log.config.loggers << MyCustomLogger
# or
Log.config.loggers = [MyCustomLogger]
```
`Log.config.loggers` is an array of the loggers that will be called by the log dispatch each time you write a log.
They will be called in the order they appear in the array.
Default: `[DBlogger, RailsLogger, ExceptionalLogger]`

```ruby
Log.config,raise_on_failed_asserts = false #boolean
```
Set to `true` if you want all asserts to raise an exception when they fail. Useful
when developing and testing.
Default: `false`

```ruby
Log.config,raise_on_log_failure = false #boolean
```
Set to true if you want to raise an exception when one of the loggers raises an
exception.
If this is `false`, `Log` will only try to log the failure using the loggers that
didn't fail.
Default: `false`

### Creating a custom logger
A logger object needs to implement the following interface:
```ruby
class YourLogger
  def self.log(severity, message, context, events, metadata)
    # record stuff here
  end
end
```

* `severity` - `Symbol`. The log level. One of the following: `debug`, `info`, `warn`, `error`, `fatal`
* `message` - `String`.
* `context` - `Hash`. Extra data that's related to the message.
* `events` - `Array`. A collection of all recorded events prior to the log call. (contents of the array covered in later section)
* `metadata` - `Hash`. Extra data related to the logging process, added by other loggers that ran prior to this one.

If your log method returns a `Hash`, it will be merged into metadata and sent to
all subsequent loggers.


### Controller Support
Also included with BatLog is the log controller support. To use it we recommend you add it to your ApplicationController
by adding these lines to it.
```ruby
require 'log/controller_support'

include Log::ControllerSupport
```
This does two things, first it adds a before_filter that captures as much data as it can into the log.context and also hooks for when a CSRF exception occurs