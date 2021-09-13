import 'package:json_annotation/json_annotation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String sid;
  final String author;
  final DateTime dateCreated;
  final String messageBody;
  final String conversationSid;
  final String participantSid;
  final Participant participant;
  final int messageIndex;
  final MessageType type;
  final bool hasMedia;
  final MessageMedia media;
  //TODO Does not serialize currently
  // final Attributes attributes;

  Message({
    this.sid,
    this.author,
    this.dateCreated,
    this.messageBody,
    this.conversationSid,
    this.participantSid,
    this.participant,
    this.messageIndex,
    this.type,
    this.hasMedia,
    this.media,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
