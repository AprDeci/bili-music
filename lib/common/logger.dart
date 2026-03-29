import 'package:logger/logger.dart';

class AppLogger {
  AppLogger(String tag) : _tag = tag;

  final String _tag;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      printTime: true,
    ),
  );

  static void dioLogPrint(Object object) {
    AppLogger('Dio').d(object.toString());
  }

  void t(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.t(_message(message), error: error, stackTrace: stackTrace);
  }

  void d(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(_message(message), error: error, stackTrace: stackTrace);
  }

  void i(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(_message(message), error: error, stackTrace: stackTrace);
  }

  void w(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(_message(message), error: error, stackTrace: stackTrace);
  }

  void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(_message(message), error: error, stackTrace: stackTrace);
  }

  void f(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(_message(message), error: error, stackTrace: stackTrace);
  }

  String _message(Object? message) {
    return '[$_tag] ${message ?? ''}'.trimRight();
  }
}
