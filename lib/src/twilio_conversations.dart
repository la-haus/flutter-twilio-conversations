import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

Map<String, dynamic> decodeMethodResultToMap(dynamic result) {
  return Map<String, dynamic>.from(
      jsonDecode(result.toString()) as Map<String, dynamic>);
}

List<Map<String, dynamic>> decodeMethodResultToList(dynamic result) {
  return (jsonDecode(result.toString()) as List)
      ?.map((i) => i as Map<String, dynamic>)
      ?.toList();
}

class TwilioConversations {
  factory TwilioConversations() => _instance;
  static final TwilioConversations _instance = TwilioConversations._();
  TwilioConversations._();

  static const MethodChannel methodChannel =
      const MethodChannel('twilio_conversations');
  static const EventChannel clientChannel =
      EventChannel('twilio_conversations/client');
  static const EventChannel notificationChannel =
      EventChannel('twilio_conversations/notification');
  static const EventChannel loggingChannel =
      EventChannel('twilio_conversations/logging');

  static bool _dartDebug = false;
  static StreamSubscription<bool> _clientListener;
  static StreamSubscription loggingStream;
  static ConversationClient conversationClient;

  /// Create a [ConversationClient].
  Future<ConversationClient> create({String jwtToken}) async {
    conversationClient = ConversationClient();
    final completer = Completer<ConversationClient>();

    _clientListener?.cancel();
    _clientListener =
        conversationClient.onClientListenerAttached.listen((event) async {
      //TODO Needs to throw a better error when trying
      // to create with a bad jwtToken. The current error is "Client timeout reached"
      // (happens in iOS, not sure about Android)
      _clientListener?.cancel();
      final result =
          await methodChannel.invokeMethod('create', {'jwtToken': jwtToken});
      if (result == null) {
        return completer.complete(null);
      }

      conversationClient
          .updateFromMap(jsonDecode(result.toString()) as Map<String, dynamic>);
      completer.complete(conversationClient);
    });

    return completer.future;
  }

  static Exception convertException(PlatformException err) {
    var code = int.tryParse(err.code);
    // If code is an integer, then it is a Twilio ErrorInfo exception.
    if (code != null) {
      return ErrorInfo(int.parse(err.code), err.message, err.details as int);
    }

    // For now just rethrow the PlatformException. But we could make custom ones based on the code value.
    // code can be:
    // - "ERROR" Something went wrong in the custom native code.
    // - "IllegalArgumentException" Something went wrong calling the twilio SDK.
    // - "JSONException" Something went wrong parsing a JSON string.
    // - "MISSING_PARAMS" Missing params, only the native debug method uses this at the moment.
    return err;
  }

  /// Internal logging method for dart.
  static void log(dynamic msg) {
    if (_dartDebug) {
      print('[   DART   ] $msg');
    }
  }

  /// Enable debug logging.
  ///
  /// For native logging set [native] to `true` and for dart set [dart] to `true`.
  static Future<void> debug({
    bool dart = false,
    bool native = false,
    bool sdk = false,
  }) async {
    assert(dart != null);
    assert(native != null);
    assert(sdk != null);
    _dartDebug = dart;
    await methodChannel.invokeMethod('debug', {'native': native, 'sdk': sdk});
    if (native && loggingStream == null) {
      loggingStream =
          loggingChannel.receiveBroadcastStream().listen((dynamic event) {
        if (native) {
          print('[  NATIVE  ] $event');
        }
      });
    } else if (!native && loggingStream != null) {
      await loggingStream.cancel();
      loggingStream = null;
    }
  }
}
