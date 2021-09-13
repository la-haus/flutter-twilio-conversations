// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageOptions _$MessageOptionsFromJson(Map<String, dynamic> json) {
  return MessageOptions(
    body: json['body'] as String,
    attributes: json['attributes'] as Map<String, dynamic>,
    inputPath: json['inputPath'] as String,
    mimeType: json['mimeType'] as String,
    filename: json['filename'] as String,
  );
}

Map<String, dynamic> _$MessageOptionsToJson(MessageOptions instance) =>
    <String, dynamic>{
      'body': instance.body,
      'attributes': instance.attributes,
      'mimeType': instance.mimeType,
      'filename': instance.filename,
      'inputPath': instance.inputPath,
    };
