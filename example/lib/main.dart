import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twilio_conversations_example/conversations/conversations_notifier.dart';
import 'package:twilio_conversations_example/conversations/conversations_page.dart';
import 'package:twilio_conversations_example/messages/messages_notifier.dart';

final conversationsNotifierProvider =
    ChangeNotifierProvider((_) => ConversationsNotifier());
final messagesNotifierProvider =
    ChangeNotifierProvider((_) => MessagesNotifier());

void main() {
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Twilio Conversations Example'),
        ),
        body: Center(
          child: _TestingButtons(),
        ),
      ),
    );
  }
}

class _TestingButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(conversationsNotifierProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          child: Text('Initialize Client'),
          onPressed: () {
            final jwtToken = ''; // <Set your JWT token here>

            if (jwtToken.isEmpty) {
              _showInvalidJWTDialog(context);
              return;
            }
            _provider.create(jwtToken: jwtToken);
          },
        ),
        ElevatedButton(
          child: Text('See My Conversations'),
          onPressed: _provider.isClientInitialized
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationsPage(),
                    ),
                  )
              : null,
        ),
      ],
    );
  }
}

void _showInvalidJWTDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: new Text("Error: No JWT provided"),
      content: new Text(
          'To create the conversations client, a JWT must be supplied on line 44 of `main.dart`'),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
