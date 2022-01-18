import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/src.dart';

import 'twilio_conversations_test.mocks.dart';

@GenerateMocks([PluginApi])
void main() {
  late TwilioConversations plugin;
  final pluginApi = MockPluginApi();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    when(pluginApi.create(any, any)).thenAnswer((realInvocation) async {
      final result = ConversationClientData();
      result.myIdentity = 'mockIdentity';
      result.connectionState = 'CONNECTED';
      result.isReachabilityEnabled = false;
      return result;
    });
    plugin = TwilioConversations.mock(
      pluginApi: pluginApi,
    );
  });

  tearDown(() {});

  test('Calls API to create ConversationClient', () async {
    final client = await plugin.create(jwtToken: 'mockToken');
    expect(client is ConversationClient, true);
    expect(client?.myIdentity, 'mockIdentity');
    expect(client?.connectionState, ConnectionState.CONNECTED);
  });
}
