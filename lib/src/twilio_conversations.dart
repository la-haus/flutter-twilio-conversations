import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class TwilioConversations extends FlutterLoggingApi {
  factory TwilioConversations() {
    _instance ??= TwilioConversations._();
    return _instance!;
  }
  static TwilioConversations? _instance;

  TwilioConversations._({
    PluginApi? pluginApi,
    ConversationApi? conversationApi,
    ParticipantApi? participantApi,
    UserApi? userApi,
    MessageApi? messageApi,
  }) {
    _pluginApi = pluginApi ?? PluginApi();
    _conversationApi = conversationApi ?? ConversationApi();
    _participantApi = participantApi ?? ParticipantApi();
    _userApi = userApi ?? UserApi();
    _messageApi = messageApi ?? MessageApi();
    FlutterLoggingApi.setup(this);
  }

  @visibleForTesting
  factory TwilioConversations.mock({
    PluginApi? pluginApi,
    ConversationApi? conversationApi,
    ParticipantApi? participantApi,
    UserApi? userApi,
    MessageApi? messageApi,
  }) {
    _instance = TwilioConversations._(
      pluginApi: pluginApi,
      conversationApi: conversationApi,
      participantApi: participantApi,
      userApi: userApi,
      messageApi: messageApi,
    );
    return _instance!;
  }

  late PluginApi _pluginApi;
  PluginApi get pluginApi => _pluginApi;

  final _conversationsClientApi = ConversationClientApi();
  ConversationClientApi get conversationsClientApi => _conversationsClientApi;

  late ConversationApi _conversationApi;
  ConversationApi get conversationApi => _conversationApi;

  late ParticipantApi _participantApi;
  ParticipantApi get participantApi => _participantApi;

  late MessageApi _messageApi;
  MessageApi get messageApi => _messageApi;

  late UserApi _userApi;
  UserApi get userApi => _userApi;

  // TODO: deprecate media progress channel and use pigeon instead
  static const EventChannel mediaProgressChannel =
      EventChannel('twilio_programmable_chat/media_progress');

  static bool _dartDebug = false;
  static ConversationClient? conversationClient;

  /// Create a [ConversationClient].
  Future<ConversationClient?> create({
    required String jwtToken,
    Properties properties = const Properties(),
  }) async {
    assert(jwtToken.isNotEmpty);

    conversationClient = ConversationClient();

    //TODO Needs to throw a better error when trying
    // to create with a bad jwtToken. The current error is "Client timeout reached"
    // (happens in iOS, not sure about Android)
    final ConversationClientData result;
    try {
      result = await pluginApi.create(jwtToken, properties.toPigeon());

      conversationClient
          ?.updateFromMap(Map<String, dynamic>.from(result.encode() as Map));
    } catch (e) {
      conversationClient = null;
      log('create => onError: $e');
      rethrow;
    }

    return conversationClient;
  }

  static Exception convertException(PlatformException err) {
    if (err.code == 'TwilioException') {
      // Formatted this way to allow for transmitting Twilio error `code`.
      // Would use `details`, but pigeon does not support usage of it on iOS.
      final parts = err.message!.split('|');
      final code = parts.first;
      final message = parts.last;
      return TwilioException(code: code, message: message);
    } else if (err.code == 'ClientNotInitializedException') {
      return ClientNotInitializedException(
        code: err.code,
        message: err.message,
        details: err.details,
      );
    } else if (err.code == 'ConversionException') {
      return ConversionException(
        code: err.code,
        message: err.message,
        details: err.details,
      );
    } else if (err.code == 'MissingParameterException') {
      return MissingParameterException(
        code: err.code,
        message: err.message,
        details: err.details,
      );
    } else if (err.code == 'NotFoundException') {
      return NotFoundException(
        code: err.code,
        message: err.message,
        details: err.details,
      );
    }
    return err;
  }

  /// Internal logging method for dart.
  static void log(dynamic msg) {
    if (_dartDebug) {
      print('[   DART   ] $msg');
    }
  }

  /// Host to Flutter logging API
  @override
  void logFromHost(String msg) {
    print('[  NATIVE  ] $msg');
  }

  /// Enable debug logging.
  ///
  /// For native logging set [native] to `true` and for dart set [dart] to `true`.
  static Future<void> debug({
    bool dart = false,
    bool native = false,
    bool sdk = false,
  }) async {
    _dartDebug = dart;
    try {
      await TwilioConversations().pluginApi.debug(native, sdk);
    } catch (e) {
      TwilioConversations.log(
          'TwilioConversations::debug => Caught Exception: $e');
    }
  }
}
