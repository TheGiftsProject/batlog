### 0.9.2 - bug fixes
 * converted DB context to be saved as JSON, ActiveRecord::Store is problematic

### 0.9.1 - bug fixes
 * BUGFIX - post a message without context

### 0.9 - Initial Release
 * Basic Functionality
   * Log.info,warn,debug,error,fatal
   * Log.assert
   * Log.context
   * Log.events
 * 3 Loggers
   * Database logger
   * Rails logger
   * Exceptional logger
 * Log::ControllerSupport