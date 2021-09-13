// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageMedia _$MessageMediaFromJson(Map<String, dynamic> json) {
  return MessageMedia(
    sid: json['sid'] as String,
    fileName: json['fileName'] as String,
    type: json['type'] as String,
    size: json['size'] as int,
    conversationSid: json['conversationSid'] as String,
    messageIndex: json['messageIndex'] as int,
  );
}

Map<String, dynamic> _$MessageMediaToJson(MessageMedia instance) =>
    <String, dynamic>{
      'sid': instance.sid,
      'fileName': instance.fileName,
      'type': instance.type,
      'size': instance.size,
      'conversationSid': instance.conversationSid,
      'messageIndex': instance.messageIndex,
    };
