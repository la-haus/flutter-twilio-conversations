import 'package:flutter/services.dart';

class TwilioException extends PlatformException {
  TwilioException({
    required String code,
    String? message,
    dynamic details,
  }) : super(
          code: code,
          message: message,
          details: details,
        );

  @override
  String toString() => 'TwilioException($code, $message, $details)';
}
