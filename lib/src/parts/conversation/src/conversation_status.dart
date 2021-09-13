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
