import 'package:flutter/foundation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class ConversationsNotifier extends ChangeNotifier {
  final plugin = TwilioConversations();
  bool isClientInitialized = false;

  List<Conversation> conversations = [];

  Future<void> create({@required String jwtToken}) async {
    TwilioConversations.debug(dart: true, native: true);

    final client = await plugin.create(jwtToken: jwtToken);

    print("Client initialized");
    print("Your Identity: ${client.myIdentity}");

    isClientInitialized = true;
    notifyListeners();

    client.onConversationAdded.listen((event) {
      conversations.add(event);
      notifyListeners();
    });
  }

  Future<Conversation> createConversation(
      {String friendlyName = 'Test Conversation'}) async {
    var result = await TwilioConversations.conversationClient.conversations
        .createConversation(friendlyName: friendlyName);
    print('Conversation successfully created: ${result.friendlyName}');
    return result;
  }

  Future<void> getMyConversations() async {
    final myConversations = await TwilioConversations
        .conversationClient.conversations
        .getMyConversations();

    if (myConversations != null) {
      conversations = myConversations;
      notifyListeners();
    }
  }
}
