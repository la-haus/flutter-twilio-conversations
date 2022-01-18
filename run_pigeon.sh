flutter pub run pigeon \
  --input pigeons/api.dart \
  --dart_out lib/api.dart \
  --objc_header_out ios/Classes/api.h \
  --objc_source_out ios/Classes/api.m \
  --objc_prefix TWCON \
  --java_out android/src/main/kotlin/twilio/flutter/twilio_conversations/Api.java \
  --java_package "twilio.flutter.twilio_conversations"