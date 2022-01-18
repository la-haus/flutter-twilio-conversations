import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:twilio_conversations_example/conversations/conversations_notifier.dart';
import 'package:twilio_conversations_example/messages/messages_page.dart';

class ConversationsPage extends StatefulWidget {
  final ConversationsNotifier conversationsNotifier;

  const ConversationsPage({
    required this.conversationsNotifier,
  });

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    widget.conversationsNotifier.getMyConversations();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConversationsNotifier>.value(
      value: widget.conversationsNotifier,
      child: Consumer<ConversationsNotifier>(
        builder: (BuildContext context, conversationsNotifier, Widget? child) {
          return WillPopScope(
            onWillPop: () async {
              conversationsNotifier.cancelSubscriptions();
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text('Conversations'),
                actions: [
                  _buildOverflowButton(),
                ],
              ),
              body: Center(
                child: _buildBody(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverflowButton() {
    return PopupMenuButton(
      icon: Icon(Icons.menu),
      onSelected: (result) {
        switch (result) {
          case ConversationsPageMenuOptions.setFriendlyName:
            _showSetFriendlyName();
            break;
          case ConversationsPageMenuOptions.createConversation:
            _showCreateConversation();
            break;
          case ConversationsPageMenuOptions.registerForNotifications:
            _registerForNotifications();
            break;
          case ConversationsPageMenuOptions.unregisterForNotifications:
            _unregisterForNotifications();
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<ConversationsPageMenuOptions>>[
        PopupMenuItem(
          value: ConversationsPageMenuOptions.setFriendlyName,
          child: Text('Set My Friendly Name'),
        ),
        PopupMenuItem(
          value: ConversationsPageMenuOptions.createConversation,
          child: Text('Create Conversation'),
        ),
        PopupMenuItem(
          value: ConversationsPageMenuOptions.registerForNotifications,
          child: Text('Register For Notifications'),
        ),
        PopupMenuItem(
          value: ConversationsPageMenuOptions.unregisterForNotifications,
          child: Text('Unregister For Notifications'),
        ),
      ],
    );
  }

  Future _showSetFriendlyName() async {
    var friendlyName = await _getFriendlyNameForUser();
    if (friendlyName != null) {
      await widget.conversationsNotifier.setFriendlyName(friendlyName);
    }
  }

  Future _showCreateConversation() async {
    var conversationName = await _getFriendlyNameForCreateConversation();
    if (conversationName != null) {
      final conversation = await widget.conversationsNotifier
          .createConversation(friendlyName: conversationName);
      print('Successfully created conversation: ${conversation?.friendlyName}');
    } else {
      print('Create conversation cancelled');
    }
  }

  Future _registerForNotifications() async {
    await widget.conversationsNotifier.registerForNotification();
  }

  Future _unregisterForNotifications() async {
    await widget.conversationsNotifier.unregisterForNotification();
  }

  Future<String?> _getFriendlyNameForUser() async {
    final controller = TextEditingController();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(
                      label: Text(
                          'My Friendly Name: ${widget.conversationsNotifier.friendlyName}')),
                  controller: controller,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(controller.text);
                      },
                      child: Text('Set Friendly Name'),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _getFriendlyNameForCreateConversation() async {
    final controller = TextEditingController();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(label: Text('Conversation Name')),
                  controller: controller,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(controller.text);
                      },
                      child: Text('Create'),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
            child: Text('Refresh Conversations'),
            onPressed: () {
              widget.conversationsNotifier.getMyConversations();
            }),
        Flexible(
          child: _buildConversationList(),
        ),
      ],
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.conversationsNotifier.conversations.length,
      itemBuilder: (_, index) {
        return _buildConversationListItem(
            widget.conversationsNotifier.conversations[index]);
      },
    );
  }

  Widget _buildConversationListItem(Conversation conversation) {
    return InkWell(
      onLongPress: () => _showConversationOptionsDialog(conversation),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesPage(
                conversation, widget.conversationsNotifier.client!),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('Conversation: ${conversation.friendlyName}'),
                          Text(
                              'Unread Messages: ${widget.conversationsNotifier.unreadMessageCounts[conversation.sid]}'),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (conversation.status != ConversationStatus.JOINED) {
                          await widget.conversationsNotifier.join(conversation);
                        } else {
                          await widget.conversationsNotifier
                              .leave(conversation);
                        }
                      },
                      child: Icon(
                          conversation.status == ConversationStatus.JOINED
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future _showConversationOptionsDialog(Conversation conversation) async {
    final option = (await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(conversation.friendlyName ?? conversation.sid),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConversationOptions.close);
                    },
                    child: Text('CLOSE'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConversationOptions.markRead);
                    },
                    child: Text('MARK READ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConversationOptions.markUnread);
                    },
                    child: Text('MARK UNREAD'),
                  ),
                ],
              );
            })) ??
        ConversationOptions.close;

    switch (option) {
      case ConversationOptions.close:
        break;
      case ConversationOptions.markRead:
        widget.conversationsNotifier.markRead(conversation);
        break;
      case ConversationOptions.markUnread:
        widget.conversationsNotifier.markUnread(conversation);
        break;
    }
  }
}

enum ConversationOptions {
  close,
  markRead,
  markUnread,
}

enum ConversationsPageMenuOptions {
  setFriendlyName,
  createConversation,
  registerForNotifications,
  unregisterForNotifications,
}
