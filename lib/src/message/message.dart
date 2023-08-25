import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/message/delivery_receipt.dart';
import 'package:twilio_conversations/src/message/detailed_delivery_receipt.dart';
import 'package:twilio_conversations/src/utils/cast.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Message {
  final String? sid;
  final int? messageIndex;
  final String? author;
  final String? subject;
  final String? body;
  final MessageType type;
  final bool hasMedia;
  final MessageMedia? media;
  final String conversationSid;
  final String? participantSid;

  //TODO: review including Participant - as we are not maintaining a collection of them at the dart layer that we would want to update, simply constructing one may be sufficient. This should continue to remain the case so long as we are not distributing events via a Participant instance
  // final Participant? participant;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;
  final String? lastUpdatedBy;
  final Attributes? attributes;

  const Message(
    this.sid,
    this.author,
    this.dateCreated,
    this.dateUpdated,
    this.lastUpdatedBy,
    this.conversationSid,
    this.subject,
    this.body,
    this.participantSid,
    // this.participant, // TODO: maybe include
    this.messageIndex,
    this.type,
    this.hasMedia,
    this.media,
    this.attributes,
  );

  /// Construct from a map.
  factory Message.fromMap(Map<String, dynamic> map) {
    final message = Message(
      map['sid'],
      map['author'],
      DateTime.parse(map['dateCreated']),
      DateTime.parse(map['dateUpdated']),
      map['lastUpdatedBy'],
      map['conversationSid'],
      map['subject'],
      map['messageBody'],
      map['participantSid'],
      map['messageIndex'],
      EnumToString.fromString(MessageType.values, map['type']) ??
          MessageType.TEXT,
      map['hasMedia'],
      map['media'] != null
          ? MessageMedia.fromMap(map['media'].cast<String, dynamic>())
          : null,
      map['attributes'] != null
          ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
          : Attributes(AttributesType.NULL, null),
    );

    return message;
  }

  // Construct from a list of attributes
  factory Message.fromObjectList(List<Object?> attributes) {
    final message = Message(
      castString(attributes[0]),
      castString(attributes[2]),
      DateTime.parse(attributes[10] as String),
      DateTime.parse(attributes[11] as String),
      castString(attributes[12]),
      attributes[8] as String,
      castString(attributes[3]),
      castString(attributes[4]),
      castString(attributes[9]),
      castInt(attributes[1]),
      EnumToString.fromString(MessageType.values, attributes[5] as String) ??
          MessageType.TEXT,
      attributes[6] as bool,
      attributes[7] != null
          ? MessageMedia.fromObjectList(attributes[7] as List<Object?>)
          : null,
      attributes[13] != null
          ? Attributes.fromObjectList(attributes[13] as List<Object?>)
          : Attributes(AttributesType.NULL, null),
    );

    return message;
  }

  factory Message.fromPigeon(MessageData messageData) {
    return Message.fromObjectList(messageData.encode() as List<Object?>);
  }

  Future<Conversation?> getConversation() async {
    try {
      return TwilioConversations.conversationClient
          ?.getConversation(conversationSid);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Save media content stream that could be streamed or downloaded by client.
  ///
  /// Provided file could be an existing file and a none existing file.
  Future<String?> getMediaUrl() async {
    try {
      final uMessageIndex = messageIndex;
      if (uMessageIndex != null) {
        final result = await TwilioConversations()
            .messageApi
            .getMediaContentTemporaryUrl(conversationSid, uMessageIndex);
        return result;
      }
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
    return null;
  }

  Future<Participant?> getParticipant() async {
    try {
      final result = await TwilioConversations()
          .messageApi
          .getParticipant(conversationSid, messageIndex!);

      final participant = Participant.fromPigeon(result);

      return participant;
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
          .messageApi
          .setAttributes(conversationSid, messageIndex!, attributesData);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<void> updateMessageBody(String messageBody) async {
    try {
      await TwilioConversations()
          .messageApi
          .updateMessageBody(conversationSid, messageIndex!, messageBody);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<DeliveryReceipt?> getDeliveryReceipt() async {
    try {
      final result = await TwilioConversations()
          .messageApi
          .getAggregatedDeliveryReceipt(conversationSid, messageIndex!);

      final deliveryReceipt = DeliveryReceipt.fromPigeon(result);

      return deliveryReceipt;
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  Future<List<DetailedDeliveryReceipt?>>
      getDetailedDeliveryReceiptList() async {
    try {
      final result = await TwilioConversations()
          .messageApi
          .getDetailedDeliveryReceiptList(conversationSid, messageIndex!);

      return result.map((element) {
        return DetailedDeliveryReceipt.fromPigeon(element!);
      }).toList();
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }
}
