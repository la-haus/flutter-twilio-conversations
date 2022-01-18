import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:uuid/uuid.dart';

import 'participant_test.mocks.dart';
import 'setup_stubs.dart';

@GenerateMocks([ParticipantApi])
void main() {
  final participantApi = MockParticipantApi();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TwilioConversations.mock(participantApi: participantApi);
  });

  tearDown(() {});

  test('Calls API to invoke set participant attributes', () async {
    ParticipantTestStubs.stubSetAttributes(participantApi);
    final participantSid = Uuid().v4();
    final conversationSid = Uuid().v4();
    final participant = ParticipantTestStubs.createMockParticipant(
        conversationSid, participantSid);
    final expectedAttributes = 173.954;
    final mockAttributes =
        Attributes(AttributesType.NUMBER, expectedAttributes.toString());

    await participant.setAttributes(mockAttributes);

    final invocation = ParticipantTestStubs.invocation;
    expect(invocation?.positionalArguments[0], conversationSid);
    expect(invocation?.positionalArguments[1], participantSid);

    final attributesData = invocation?.positionalArguments[2];
    expect(attributesData.type,
        EnumToString.convertToString(AttributesType.NUMBER));
    expect(attributesData.data, expectedAttributes.toString());
  });
}
