import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

import 'participant_test.mocks.dart';

class ParticipantTestStubs {
  static Invocation? invocation;
  static final chatType = 'CHAT';

  static void stubSetAttributes(MockParticipantApi participantApi) {
    when(participantApi.setAttributes(any, any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return;
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
