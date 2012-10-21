# Log v0.9
## Setup
`Log` collects different kinds of data, but doesn't record them anywhere. To do 
that, you must create at least one logger object.

### Creating a logger
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

### Initializing `Log`
```ruby
Log.loggers([Array, Of, Loggers])
```
Pass an array of loggers to `Log.loggers` to set the list of loggers that will 
be called to save the data.
They will be called in the order they appear in the array.
Default: `[]`

```ruby
Log.raise_on_failed_asserts(boolean)
```
Set to `true` if you want all asserts to raise an exception when they fail. Useful 
when developing and testing.
Default: `false`

```ruby
Log.raise_on_log_failure(boolean)
```
Set to true if you want to raise an exception when one of the loggers raises an 
exception.
If this is `false`, `Log` will only try to log the failure using the loggers that 
didn't fail.
Default: `false`


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
