import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

part 'participant.g.dart';

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
  CHAT,
  OTHER,
  SMS,
  UNSET,
  WHATSAPP,
  UNKNOWN,
}

@JsonSerializable()
class Participant {
  final Attributes attributes;
  final String conversationSid;
  final String dateCreated;
  final String dateUpdated;
  final String identity;
  final int lastReadMessageIndex;
  final String lastReadTimestamp;
  final String sid;
  final Type type;

  @JsonKey(ignore: true)
  User _user;

  Participant({
    this.attributes,
    this.conversationSid,
    this.dateCreated,
    this.dateUpdated,
    this.identity,
    this.lastReadMessageIndex,
    this.lastReadTimestamp,
    this.sid,
    this.type,
  });

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);

  Future<User> getUser() async {
    if (_user != null) {
      return _user;
    }

    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ParticipantMethods.getUser',
        {'conversationSid': conversationSid, 'participantSid': sid});
    if (result == null) {
      return null;
    }
    return _user =
        User.fromJson(jsonDecode(result.toString()) as Map<String, dynamic>);
  }
}
