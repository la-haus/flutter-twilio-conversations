import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:twilio_conversations_example/main.dart';

class MessagesPage extends StatefulWidget {
  final Conversation conversation;

  MessagesPage(this.conversation);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(messagesNotifierProvider).init(widget.conversation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.friendlyName ?? ''),
      ),
      body: Center(
        child: _PageBody(),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              color: Colors.grey[100],
              child: _ListStates(),
            ),
          )),
          _ParticipantsTyping(),
          _MessageInputBar(),
        ],
      ),
    );
  }
}

class _ListStates extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(messagesNotifierProvider);

    if (_provider.isLoading && _provider.messages.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (_provider.isError) {
      return Center(
        child: IconButton(
          icon: Icon(Icons.replay),
          onPressed: () {
            _provider.refetchAfterError();
          },
        ),
      );
    }

    if (_provider.messages.isEmpty) {
      return Center(
        child: Icon(
          Icons.speaker_notes_off,
          size: 48,
        ),
      );
    }

    return _List();
  }
}

class _List extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(messagesNotifierProvider);

    var listCount = _provider.messages.length;
    if (_provider.isLoading) {
      //Increment list count by 1
      // so that loading spinner can be shown above existing messages
      // when retrieving the next page
      listCount += 1;
    }
    return ListView.builder(
      controller: _provider.listScrollController,
      reverse: true,
      itemCount: listCount,
      itemBuilder: (_, index) {
        if (listCount == _provider.messages.length + 1 && index == listCount - 1) {
          return Center(child: CircularProgressIndicator());
        }
        return _ListItem(_provider.messages[index]);
      },
    );
  }
}

class _ListItem extends StatelessWidget {
  final Message message;

  _ListItem(this.message);

  @override
  Widget build(BuildContext context) {
    final isMyMessage = message.author == TwilioConversations.conversationClient.myIdentity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _ChatBubble(this.message),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;

  _ChatBubble(this.message);

  String parseDateTime(DateTime timestamp, {String format = 'MMM d, h:mm a'}) {
    final dateTime = timestamp?.toLocal();
    return dateTime != null ? DateFormat(format).format(dateTime).toString() : null;
  }

  @override
  Widget build(BuildContext context) {
    final isMyMessage = message.author == TwilioConversations.conversationClient.myIdentity;

    final textColor = isMyMessage ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 4.0),
          constraints: BoxConstraints(maxWidth: 250, minHeight: 35),
          decoration: BoxDecoration(
              color: isMyMessage ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
            child: Column(
              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _AuthorName(message: message, isMyMessage: isMyMessage, textColor: textColor),
                Text(
                  message.messageBody ?? '',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          parseDateTime(message.dateCreated) ?? '',
          textAlign: isMyMessage ? TextAlign.start : TextAlign.end,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _AuthorName extends ConsumerWidget {
  final bool isMyMessage;
  final Color textColor;
  final Message message;

  const _AuthorName(
      {Key key, @required this.isMyMessage, @required this.textColor, @required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return (isMyMessage)
        ? Container(
            width: 0,
          )
        : Column(
            crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                (!isMyMessage) ? message.author : '',
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
            ],
          );
  }
}

class _ParticipantsTyping extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(messagesNotifierProvider);
    final _currentlyTypingParticipants = _provider.currentlyTyping;

    return _currentlyTypingParticipants.isNotEmpty
        ? Text('${_currentlyTypingParticipants.join(', ')} is typing...')
        : Container();
  }
}

class _MessageInputBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(messagesNotifierProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 8, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: TextField(
                controller: _provider.messageInputTextController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 8,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Message',
                  contentPadding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4, top: 0),
                ),
              ),
            ),
          ),
          _SendButton(),
        ],
      ),
    );
  }
}

class _SendButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _provider = watch(messagesNotifierProvider);
    final isEmptyInput = (_provider.messageInputTextController.text ?? '').isEmpty;
    if (_provider.isSendingMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: isEmptyInput ? 8 : 44,
      child: isEmptyInput
          ? Container()
          : IconButton(
              color: Colors.blue,
              icon: Icon(Icons.send),
              onPressed: _provider.onSendMessagePressed,
            ),
    );
  }
}
