import 'package:flutter/services.dart';

class ClientNotInitializedException extends PlatformException {
  ClientNotInitializedException({
    required String code,
    String? message,
    dynamic details,
  }) : super(
          code: code,
          message: message,
          details: details,
        );

  @override
  String toString() =>
      'ClientNotInitializedException($code, $message, $details)';
}
