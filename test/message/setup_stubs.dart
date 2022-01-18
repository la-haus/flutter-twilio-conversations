import 'package:enum_to_string/enum_to_string.dart';
import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

import 'message_test.mocks.dart';

class MessageTestStubs {
  static Invocation? invocation;
  static final chatType = 'CHAT';

  static void stubGetParticipant(
      MockMessageApi participantApi, Participant participant) {
    when(participantApi.getParticipant(any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      final result = ParticipantData()
        ..sid = participant.sid
        ..type = EnumToString.convertToString(participant.type)
        ..conversationSid = participant.conversationSid;
      return result;
    });
  }

  static void stubSetAttributes(MockMessageApi participantApi) {
    when(participantApi.setAttributes(any, any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return;
    });
  }

  static void stubUpdateMessageBody(MockMessageApi participantApi) {
    when(participantApi.updateMessageBody(any, any, any))
        .thenAnswer((realInvocation) async {
      invocation = realInvocation;
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
