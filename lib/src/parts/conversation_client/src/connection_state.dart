/// Represents underlying twilsock connection state.
enum ConnectionState {
  /// Transport is trying to connect and register or trying to recover.
  CONNECTING,

  /// Transport is working.
  CONNECTED,

  /// Transport is not working.
  DISCONNECTED,

  /// Transport was not enabled because authentication token is invalid or not authorized.
  DENIED,

  /// Error in connecting or sending transport message. Possibly due to offline.
  ERROR,

  /// Server has rejected enabling transport and customer action is required.
  FATAL_ERROR,

  /// Unknown connection state
  UNKNOWN,
}
