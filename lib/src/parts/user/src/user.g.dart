// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['attributes'] == null
        ? null
        : Attributes.fromJson(json['attributes'] as Map<String, dynamic>),
    json['friendlyName'] as String,
    json['identity'] as String,
    json['isNotifiable'] as bool,
    json['isOnline'] as bool,
    json['isSubscribed'] as bool,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'attributes': instance.attributes,
      'friendlyName': instance.friendlyName,
      'identity': instance.identity,
      'isNotifiable': instance.isNotifiable,
      'isOnline': instance.isOnline,
      'isSubscribed': instance.isSubscribed,
    };
