// ignore_for_file: constant_identifier_names

/// Indicates reason for member info update.
enum ParticipantUpdateReason {
  /// Participant last read message index has changed.
  /// <p>
  /// This update event is fired when participant's read horizon changes. This usually
  /// indicates that some messages were read by that participant.
  LAST_READ_MESSAGE_INDEX,

  /// Participant last read message timestamp has changed.
  /// <p>
  /// This update event is fired when participant's read horizon changes (or just set to the same position again).
  /// This usually indicates that some messages were read by that participant.
  LAST_READ_TIMESTAMP,

  /// Participant attributes have changed.
  /// <p>
  /// This update event is fired when participant's attributes change.
  ATTRIBUTES
}

enum UpdateReason {
  /// Participant last read message index has changed.
  /// <p>
  /// This update event is fired when participant's read horizon changes. This usually
  /// indicates that some messages were read by that participant.
  LAST_READ_MESSAGE_INDEX,

  /// Participant last read message timestamp has changed.
  /// <p>
  /// This update event is fired when participant's read horizon changes (or just set to the same position again).
  /// This usually indicates that some messages were read by that participant.
  LAST_READ_TIMESTAMP,

  /// Participant attributes have changed.
  /// <p>
  /// This update event is fired when participant's attributes change.
  ATTRIBUTES
}

enum Type {
  UNSET,
  OTHER,
  CHAT,
  SMS,
  WHATSAPP,
}
