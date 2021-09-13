// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    sid: json['sid'] as String,
    author: json['author'] as String,
    dateCreated: json['dateCreated'] == null
        ? null
        : DateTime.parse(json['dateCreated'] as String),
    messageBody: json['messageBody'] as String,
    conversationSid: json['conversationSid'] as String,
    participantSid: json['participantSid'] as String,
    participant: json['participant'] == null
        ? null
        : Participant.fromJson(json['participant'] as Map<String, dynamic>),
    messageIndex: json['messageIndex'] as int,
    type: _$enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
    hasMedia: json['hasMedia'] as bool,
    media: json['media'] == null
        ? null
        : MessageMedia.fromJson(json['media'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'sid': instance.sid,
      'author': instance.author,
      'dateCreated': instance.dateCreated?.toIso8601String(),
      'messageBody': instance.messageBody,
      'conversationSid': instance.conversationSid,
      'participantSid': instance.participantSid,
      'participant': instance.participant,
      'messageIndex': instance.messageIndex,
      'type': _$MessageTypeEnumMap[instance.type],
      'hasMedia': instance.hasMedia,
      'media': instance.media,
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

const _$MessageTypeEnumMap = {
  MessageType.TEXT: 'TEXT',
  MessageType.MEDIA: 'MEDIA',
};
