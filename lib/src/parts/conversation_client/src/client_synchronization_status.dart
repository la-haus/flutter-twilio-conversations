/// Represents client initialization status.
enum ClientSynchronizationStatus {
  /// [Client] Initialization is started.
  STARTED,

  /// [Conversation] list initialization is completed.
  CONVERSATIONS_COMPLETED,

  /// [Client] Initialization completed.
  COMPLETED,

  /// [Client] Initialization failed.
  FAILED,

  UNKNOWN,
}
