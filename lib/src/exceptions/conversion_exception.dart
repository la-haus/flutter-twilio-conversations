import 'package:flutter/services.dart';

class ConversionException extends PlatformException {
  ConversionException({
    required String code,
    String? message,
    dynamic details,
  }) : super(
          code: code,
          message: message,
          details: details,
        );

  @override
  String toString() => 'ConversionException($code, $message, $details)';
}
