// ignore_for_file: constant_identifier_names

/// Represents the various statuses of the user with respect to the conversation.
enum ConversationStatus {
  /// [User] has joined this conversation.
  JOINED,

  /// [User] has NOT joined this conversation.
  NOT_PARTICIPATING,

  /// [Conversation] has not been synched and it's actual status is unknown.
  ///
  /// ChannelDescriptors will have this value set for status.
  UNKNOWN,
}

/// Indicates synchronization status for conversation.
enum ConversationSynchronizationStatus {
  /// Local copy, does not exist in cloud.
  NONE,

  /// [Conversation] SID, not synchronized with cloud.
  IDENTIFIER,

  /// [Conversation] metadata: friendly name, conversation SID, attributes, unique name.
  METADATA,

  /// [Conversation] collections: participants, messages can be fetched.
  ALL,

  /// [Conversation] synchronization failed.
  FAILED,
}

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

enum NotificationLevel {
  DEFAULT,
  MUTED,
}
