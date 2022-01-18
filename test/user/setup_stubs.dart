import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

import 'user_test.mocks.dart';

class UserTestStubs {
  static Invocation? invocation;

  static void stubSetAttributes(MockUserApi userApi) {
    when(userApi.setAttributes(any, any)).thenAnswer((realInvocation) async {
      invocation = realInvocation;
      return;
    });
  }

  static User createMockUser(
      String identity, Attributes attributes, String? friendlyName) {
    final user = User(identity, attributes, friendlyName, false, false, false);
    return user;
  }
}
