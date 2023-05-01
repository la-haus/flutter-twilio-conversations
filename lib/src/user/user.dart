import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/utils/cast.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class User {
  final String _identity;
  Attributes _attributes;
  String? _friendlyName;
  bool _isNotifiable = false;
  bool _isOnline = false;
  bool _isSubscribed = false;

  //#region Public API properties
  /// Method that returns the friendlyName from the user info.
  String? get friendlyName {
    return _friendlyName;
  }

  /// Returns the identity of the user.
  String get identity {
    return _identity;
  }

  /// Return user's online status, if available,
  bool get isOnline {
    return _isOnline;
  }

  /// Return user's push reachability.
  bool get isNotifiable {
    return _isNotifiable;
  }

  /// Check if this user receives real-time status updates.
  bool get isSubscribed {
    return _isSubscribed;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }

  //#endregion

  User(
    this._identity,
    this._attributes,
    this._friendlyName,
    this._isNotifiable,
    this._isOnline,
    this._isSubscribed,
  );

  /// Construct from a map.
  factory User.fromMap(Map<String, dynamic> map) {
    final user = User(
      map['identity'],
      map['attributes'] != null
          ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
          : Attributes(AttributesType.NULL, null),
      map['friendlyName'],
      map['isNotifiable'] ?? false,
      map['isOnline'] ?? false,
      map['isSubscribed'] ?? false,
    );
    return user;
  }

  /// Construct from a list of attributes.
  factory User.fromObjectList(List<Object?> attributes) {
    final user = User(
      attributes[0] as String,
      attributes[1] != null
          ? Attributes.fromObjectList(attributes[1] as List<Object?>)
          : Attributes(AttributesType.NULL, null),
      castString(attributes[2]),
      attributes[3] as bool,
      attributes[4] as bool,
      attributes[5] as bool,
    );
    return user;
  }

  factory User.fromPigeon(UserData userData) {
    return User.fromObjectList(userData.encode() as List<Object?>);
  }

  Future<void> setFriendlyName(String friendlyName) async {
    try {
      await TwilioConversations()
          .userApi
          .setFriendlyName(identity, friendlyName);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<void> setAttributes(Attributes attributes) async {
    try {
      final attributesData = AttributesData()
        ..type = EnumToString.convertToString(attributes.type)
        ..data = attributes.data;
      await TwilioConversations()
          .userApi
          .setAttributes(identity, attributesData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }
}
