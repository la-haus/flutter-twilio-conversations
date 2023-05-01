import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/utils/cast.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Participant {
  final String sid;
  final String conversationSid;
  final Type type;

  Attributes _attributes;

  Attributes get attributes => _attributes;

  String? _dateCreated;

  String? get dateCreated => _dateCreated;

  String? _dateUpdated;

  String? get dateUpdated => _dateUpdated;

  String? _identity;

  String? get identity => _identity;

  int? _lastReadMessageIndex;

  int? get lastReadMessageIndex => _lastReadMessageIndex;

  String? _lastReadTimestamp;

  String? get lastReadTimestamp => _lastReadTimestamp;

  Participant(
    this.sid,
    this.type,
    this.conversationSid,
    this._attributes,
    this._dateCreated,
    this._dateUpdated,
    this._identity,
    this._lastReadMessageIndex,
    this._lastReadTimestamp,
  );

  /// Construct from a map.
  factory Participant.fromMap(Map<String, dynamic> map) {
    final participant = Participant(
      map['sid'],
      EnumToString.fromString(Type.values, map['type']) ?? Type.UNSET,
      map['conversationSid'],
      map['attributes'] != null
          ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
          : Attributes(AttributesType.NULL, null),
      map['dateCreated'],
      map['dateUpdated'],
      map['identity'],
      map['lastReadMessageIndex'],
      map['lastReadTimestamp'],
    );
    return participant;
  }

  /// Construct from a list of attributes.
  factory Participant.fromObjectList(List<Object?> attributes) {
    final participant = Participant(
      attributes[0] as String,
      EnumToString.fromString(Type.values, attributes[2] as String) ??
          Type.UNSET,
      attributes[1] as String,
      attributes[3] != null
          ? Attributes.fromObjectList(attributes[3] as List<Object?>)
          : Attributes(AttributesType.NULL, null),
      castString(attributes[4]),
      castString(attributes[5]),
      castString(attributes[6]),
      castInt(attributes[7]),
      castString(attributes[8]),
    );
    return participant;
  }

  factory Participant.fromPigeon(ParticipantData participantData) {
    return Participant.fromObjectList(
        participantData.encode() as List<Object?>);
  }

  Future<User?> getUser() async {
    try {
      final result = await TwilioConversations()
          .participantApi
          .getUser(conversationSid, sid);

      return User.fromObjectList(result.encode() as List<Object?>);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<Conversation?> getConversation() async {
    return TwilioConversations.conversationClient!
        .getConversation(conversationSid);
  }

  Future<void> setAttributes(Attributes attributes) async {
    try {
      final attributesData = AttributesData()
        ..type = EnumToString.convertToString(attributes.type)
        ..data = attributes.data;
      await TwilioConversations()
          .participantApi
          .setAttributes(conversationSid, sid, attributesData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<void> remove() async {
    try {
      await TwilioConversations().participantApi.remove(conversationSid, sid);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }
}
