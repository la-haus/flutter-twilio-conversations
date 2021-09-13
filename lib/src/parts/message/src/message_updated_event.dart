import 'package:twilio_conversations/twilio_conversations.dart';

class MessageUpdatedEvent {
  final Message message;

  final MessageUpdateReason reason;

  MessageUpdatedEvent(this.message, this.reason)
      : assert(message != null),
        assert(reason != null);
}
