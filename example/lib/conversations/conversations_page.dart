import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:twilio_conversations_example/main.dart';
import 'package:twilio_conversations_example/messages/messages_page.dart';

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(conversationsNotifierProvider).getMyConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        actions: [
          _CreateConversation(),
        ],
      ),
      body: Center(
        child: _PageBody(),
      ),
    );
  }
}

class _CreateConversation extends ConsumerWidget {
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(conversationsNotifierProvider);

    return IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          var conversation =
              await _provider.createConversation(friendlyName: 'New Test 2');
          var joined = await conversation.join();
          print('Successfully joined ${conversation.friendlyName}: $joined');
        });
  }
}

class _PageBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(conversationsNotifierProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
            child: Text('Refresh Conversations'),
            onPressed: () {
              _provider.getMyConversations();
            }),
        Flexible(
          child: _List(),
        ),
      ],
    );
  }
}

class _List extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(conversationsNotifierProvider);
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: _provider.conversations?.length ?? 0,
      itemBuilder: (_, index) {
        return _ConversationListItem(_provider.conversations[index]);
      },
    );
  }
}

class _ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  _ConversationListItem(this.conversation);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        var a = await conversation.participants
            .addParticipantByIdentity("+17175555555");
        print('User added: ${a.toString()}');
        // var newMessage = await conversation.messages.sendMessage("Test texts");
        // print('New Message text is: ${newMessage.messageBody}');
      },
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MessagesPage(conversation)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(conversation.friendlyName ?? ''),
          ],
        ),
      ),
    );
  }
}
