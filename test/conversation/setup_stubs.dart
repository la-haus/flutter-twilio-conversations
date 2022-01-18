import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:uuid/uuid.dart';

import 'conversation_test.mocks.dart';

class ConversationTestStubs {
  static Invocation? invocation;
  static final chatType = 'CHAT';

  static void stubRemoveMessage(
      MockConversationApi conversationApi, bool response) {
    when(conversationApi.removeMessage(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return response;
    });
  }

  static void stubRemoveParticipant(
      MockConversationApi conversationApi, bool response) {
    when(conversationApi.removeParticipant(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return response;
    });
  }

  static void stubGetParticipantByIdentity(
      MockConversationApi conversationApi) {
    when(conversationApi.getParticipantByIdentity(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = ParticipantData();
      responseData.sid = Uuid().v4();
      responseData.type = chatType;
      responseData.conversationSid = invocation?.positionalArguments[0];
      responseData.identity = invocation?.positionalArguments[1];
      return responseData;
    });
  }

  static void stubGetParticipantBySid(MockConversationApi conversationApi) {
    when(conversationApi.getParticipantBySid(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = ParticipantData();
      responseData.sid = invocation?.positionalArguments[1];
      responseData.type = chatType;
      responseData.conversationSid = invocation?.positionalArguments[0];
      responseData.identity = Uuid().v4();
      return responseData;
    });
  }

  static void stubAdvanceLastReadMessageIndex(
      MockConversationApi conversationApi, int updatedUnreadMessageCount) {
    when(conversationApi.advanceLastReadMessageIndex(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = MessageCount();
      responseData.count = updatedUnreadMessageCount;
      return responseData;
    });
  }

  static void stubSetAllMessagesRead(
      MockConversationApi conversationApi, int updatedUnreadMessageCount) {
    when(conversationApi.setAllMessagesRead(any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = MessageCount();
      responseData.count = updatedUnreadMessageCount;
      return responseData;
    });
  }

  static void stubSetAllMessagesUnread(
      MockConversationApi conversationApi, int updatedUnreadMessageCount) {
    when(conversationApi.setAllMessagesUnread(any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = MessageCount();
      responseData.count = updatedUnreadMessageCount;
      return responseData;
    });
  }

  static void stubGetMessagesAfter(MockConversationApi conversationApi) {
    when(conversationApi.getMessagesAfter(any, any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = <MessageData>[];
      return responseData;
    });
  }

  static void stubGetMessagesBefore(MockConversationApi conversationApi) {
    when(conversationApi.getMessagesBefore(any, any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final responseData = <MessageData>[];
      return responseData;
    });
  }

  static void stubSetFriendlyName(MockConversationApi conversationApi) {
    when(conversationApi.setFriendlyName(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return;
    });
  }

  static void stubSetUniqueName(MockConversationApi conversationApi) {
    when(conversationApi.setUniqueName(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return;
    });
  }

  static void stubGetParticipantsCount(
      MockConversationApi conversationApi, int expectedCount) {
    when(conversationApi.getParticipantsCount(any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return expectedCount;
    });
  }

  static Participant createMockParticipant(
      String conversationSid, String participantSid) {
    final participant = Participant(
      participantSid,
      Type.CHAT,
      conversationSid,
      Attributes(AttributesType.NULL, null),
      null,
      null,
      null,
      null,
      null,
    );
    return participant;
  }

  static Message createMockMessage(String conversationSid, int messageIndex) {
    final message = Message(null, null, null, null, null, conversationSid, null,
        null, null, messageIndex, MessageType.TEXT, false, null, null);
    return message;
  }
}
