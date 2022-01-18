import 'package:twilio_conversations/twilio_conversations.dart';

class NotificationRegistrationEvent {
  final bool isSuccessful;
  final ErrorInfo? error;

  NotificationRegistrationEvent(this.isSuccessful, this.error);

  @override
  String toString() {
    return 'NotificationRegistrationEvent: isSuccessful: $isSuccessful, error: $error';
  }
}

class ConversationUpdatedEvent {
  final Conversation conversation;
  final ConversationUpdateReason reason;

  ConversationUpdatedEvent(this.conversation, this.reason);
}

class UserUpdatedEvent {
  final User user;

  final UserUpdateReason reason;

  UserUpdatedEvent(this.user, this.reason);
}

class NewMessageNotificationEvent {
  final String conversationSid;
  final int messageIndex;

  NewMessageNotificationEvent(this.conversationSid, this.messageIndex);
}
