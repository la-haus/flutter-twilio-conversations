/// Indicates reason for conversation update.
enum ConversationUpdateReason {
  /// [Conversation] attributes changed.
  ATTRIBUTES,

  /// [Conversation] friendly name changed.
  FRIENDLY_NAME,

  /// Last message in conversation changed.
  ///
  /// This update does not trigger when message itself changes, there's [MessageUpdateReason] event for that.
  /// However, if a new message is added or last conversation message is deleted this event will be triggered.
  LAST_MESSAGE,

  /// [Conversation] last read message changed.
  LAST_READ_MESSAGE_INDEX,

  /// Notification leven changed.
  NOTIFICATION_LEVEL,

  /// [Conversation] state changed.
  STATE,

  /// [Conversation] status changed.
  STATUS,

  /// [Conversation] unique name changed.
  UNIQUE_NAME,
}
