import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:uuid/uuid.dart';

import 'user_test.mocks.dart';
import 'setup_stubs.dart';

@GenerateMocks([UserApi])
void main() {
  final userApi = MockUserApi();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TwilioConversations.mock(userApi: userApi);
  });

  tearDown(() {});

  test('Calls API to invoke set user attributes', () async {
    UserTestStubs.stubSetAttributes(userApi);
    final userIdentity = Uuid().v4();
    final initialAttributesValue = 1854.1457;
    final userAttributes =
        Attributes(AttributesType.NUMBER, initialAttributesValue.toString());
    final user =
        UserTestStubs.createMockUser(userIdentity, userAttributes, null);

    final expectedAttributesValue = jsonEncode([17.3, "index1", null]);
    final expectedAttributes =
        Attributes(AttributesType.ARRAY, expectedAttributesValue);

    await user.setAttributes(expectedAttributes);

    final invocation = UserTestStubs.invocation;
    expect(invocation?.positionalArguments[0], userIdentity);

    final attributesData = invocation?.positionalArguments[1];
    expect(attributesData.type,
        EnumToString.convertToString(expectedAttributes.type));
    expect(attributesData.data, expectedAttributesValue);
  });
}
