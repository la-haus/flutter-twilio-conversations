// ignore_for_file: constant_identifier_names

/// Represents the type of message.
enum MessageType {
  /// [Message] is a regular text message.
  TEXT,

  /// [Message] is a media message.
  ///
  /// [Message.media] will return the associated media object.
  MEDIA,
}

/// Indicates reason for message update.
enum MessageUpdateReason {
  /// [Message] body has been updated.
  BODY,

  /// [Message] attributes have been updated.
  ATTRIBUTES,

  /// [Message] aggregated delivery receipt has been updated.
  DELIVERY_RECEIPT,
}

enum DeliveryAmount {
  /// The amount for the delivery statuses is 0.
  NONE,

  /// Amount of the delivery statuses is at least 1.
  SOME,

  /// Amount of the delivery statuses equals the maximum number of delivery events expected for that message.
  ALL,
}
