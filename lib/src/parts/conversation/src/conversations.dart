import 'package:flutter/foundation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Conversations {
  static final Map<String, Conversation> conversationsMap = {};

  Future<Conversation> getConversation({@required String conversationSidOrUniqueName}) async {
    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ConversationsMethods.getConversation',
        {'conversationSidOrUniqueName': conversationSidOrUniqueName});
    final conversationMap = decodeMethodResultToMap(result);
    updateConversationFromMap(conversationMap);
    return conversationsMap[conversationMap['sid']];
  }

  Future<Conversation> createConversation({@required String friendlyName}) async {
    final result = await TwilioConversations.methodChannel
        .invokeMethod('ConversationsMethods.createConversation', {'friendlyName': friendlyName});
    final conversationMap = decodeMethodResultToMap(result);
    updateConversationFromMap(conversationMap);
    return conversationsMap[conversationMap['sid']];
  }

  Future<List<Conversation>> getMyConversations() async {
    final result = await TwilioConversations.methodChannel
        .invokeMethod('ConversationsMethods.getMyConversations');
    final conversationsMapList = decodeMethodResultToList(result);
    conversationsMapList.forEach((element) {
      updateConversationFromMap(element);
    });

    return conversationsMap.values.toList();
  }

  /// Update individual Conversation from a map.
  static void updateConversationFromMap(Map<String, dynamic> map) {
    var sid = map['sid'] as String;
    if (conversationsMap[sid] == null) {
      conversationsMap[sid] = Conversation.fromMap(map);
    } else {
      conversationsMap[sid].updateFromMap(map);
    }
  }
}
