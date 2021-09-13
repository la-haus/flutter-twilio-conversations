import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime_type/mime_type.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Messages {
  Conversation conversation;
  Messages(this.conversation) : assert(conversation != null);

  Future<List<Message>> getLastMessages(int count) async {
    if (!conversation.hasMessages) {
      return [];
    }
    final result = await attemptSdkCall('MessagesMethods.getLastMessages', {
      'count': count,
      'conversationSid': conversation.sid,
    });

    var messages = (jsonDecode(result.toString()) as List)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    return messages;
  }

  Future<Message> sendAttachment(File attachment) async {
    var messageOptions = MessageOptions()..withMedia(attachment, mime(attachment.path));

    final result = await attemptSdkCall('MessagesMethods.sendMessage',
        {'options': messageOptions.toJson(), 'conversationSid': conversation.sid});

    return Message.fromJson(jsonDecode(result.toString()) as Map<String, dynamic>);
  }

  Future<Message> sendMessage(String messageBody) async {
    MessageOptions messageOptions =  MessageOptions()..withBody(messageBody);

    final result = await attemptSdkCall('MessagesMethods.sendMessage',
        {'options': messageOptions.toJson(), 'conversationSid': conversation.sid});

    return Message.fromJson(jsonDecode(result.toString()) as Map<String, dynamic>);
  }

  /// Fetch at most count messages including and prior to the specified index.
  Future<List<Message>> getMessagesBefore({
    @required int index,
    @required int count,
  }) async {
    assert(index != null, 'getMessagesBefore must have non-null index');
    assert(count != null, 'getMessagesBefore must have non-null count');
    if (!conversation.hasMessages) {
      return [];
    }
    try {
      final result = await attemptSdkCall('MessagesMethods.getMessagesBefore', {
        'index': index,
        'count': count,
        'conversationSid': conversation.sid,
      });

      final messages = (jsonDecode(result.toString()) as List)
          .map((i) => Message.fromJson(i as Map<String, dynamic>))
          .toList();

      return messages;
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<int> setLastReadMessageIndex(int lastReadMessageIndex) async {
    try {
      return await attemptSdkCall<int>('MessagesMethods.setLastReadMessageIndex',
          {'conversationSid': conversation.sid, 'lastReadMessageIndex': lastReadMessageIndex});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<int> setAllMessagesRead() async {
    if (!conversation.hasMessages) {
      return 0;
    }
    try {
      return await attemptSdkCall<int>(
          'MessagesMethods.setAllMessagesRead', {'conversationSid': conversation.sid});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<T> attemptSdkCall<T>(String methodName, Map<String, dynamic> map) async {
    if (conversation.synchronizationStatus == ConversationSynchronizationStatus.ALL) {
      T result = await TwilioConversations.methodChannel.invokeMethod(methodName, map);
      return result;
    } else {
      return Future.delayed(Duration(milliseconds: 200), () {
        return attemptSdkCall(methodName, map);
      });
    }
  }
}
