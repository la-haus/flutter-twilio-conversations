/// Indicates reason for message update.
enum MessageUpdateReason {
  /// [Message] body has been updated.
  BODY,

  /// [Message] attributes have been updated.
  ATTRIBUTES,

  /// [Message] aggregated delivery receipt has been updated.
  DELIVERY_RECEIPT
}
