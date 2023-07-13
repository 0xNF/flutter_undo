import 'package:dart_ilogger/dart_ilogger.dart';

/// public Hookpoint for attaching anything implementing an ILogger
ILogger get logger => _logger;
ILogger _logger = const BasicLogger(name: "Flutter_Undo_Logger");

/// Sets a Hooked Logger for the library. If `logger` is `null`, then no messages will be logged
void setLoggerHook(ILogger? logger) {
  _logger = logger ?? const NullLogger(name: "Flutter_Undo_Null_Logger");
}
