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
