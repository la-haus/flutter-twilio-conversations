// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) {
  return Participant(
    attributes: json['attributes'] == null
        ? null
        : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
    conversationSid: json['conversationSid'] as String,
    dateCreated: json['dateCreated'] as String,
    dateUpdated: json['dateUpdated'] as String,
    identity: json['identity'] as String,
    lastReadMessageIndex: json['lastReadMessageIndex'] as int,
    lastReadTimestamp: json['lastReadTimestamp'] as String,
    sid: json['sid'] as String,
    type: _$enumDecodeNullable(_$TypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'attributes': instance.attributes,
      'conversationSid': instance.conversationSid,
      'dateCreated': instance.dateCreated,
      'dateUpdated': instance.dateUpdated,
      'identity': instance.identity,
      'lastReadMessageIndex': instance.lastReadMessageIndex,
      'lastReadTimestamp': instance.lastReadTimestamp,
      'sid': instance.sid,
      'type': _$TypeEnumMap[instance.type],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$TypeEnumMap = {
  Type.CHAT: 'CHAT',
  Type.OTHER: 'OTHER',
  Type.SMS: 'SMS',
  Type.UNSET: 'UNSET',
  Type.WHATSAPP: 'WHATSAPP',
  Type.UNKNOWN: 'UNKNOWN',
};
