import 'package:json_annotation/json_annotation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final Attributes attributes;
  final String friendlyName;
  final String identity;
  final bool isNotifiable;
  final bool isOnline;
  final bool isSubscribed;

  User(
    this.attributes,
    this.friendlyName,
    this.identity,
    this.isNotifiable,
    this.isOnline,
    this.isSubscribed,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Future<void> unsubscribe() async {
  //   try {
  //     // TODO(WLFN): It is still in the [Users.subscribedUsers] list...
  //     await TwilioConversations.methodChannel
  //         .invokeMethod('User#unsubscribe', {'identity': _identity});
  //   } on PlatformException catch (err) {
  //     throw TwilioConversations.convertException(err);
  //   }
  // }
}
