import 'package:json_annotation/json_annotation.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

part 'message_media.g.dart';

@JsonSerializable()
class MessageMedia {
  final String sid;
  final String fileName;
  final String type;
  final int size;
  final String conversationSid;
  final int messageIndex;

  MessageMedia({
    this.sid,
    this.fileName,
    this.type,
    this.size,
    this.conversationSid,
    this.messageIndex,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) =>
      _$MessageMediaFromJson(json);

  Map<String, dynamic> toJson() => _$MessageMediaToJson(this);

  //#region Public API methods
  /// Save media content stream that could be streamed or downloaded by client.
  ///
  /// Provided file could be an existing file and a none existing file.
  Future<String> getMediaUrl() async {
    final response = await TwilioConversations.methodChannel
        .invokeMethod('MessageMethods.getMediaContentTemporaryUrl', {
      'conversationSid': conversationSid,
      'messageIndex': messageIndex,
    });
    return response as String;
  }
}
