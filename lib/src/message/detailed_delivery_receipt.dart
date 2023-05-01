import 'package:twilio_conversations/api.dart';
import 'package:twilio_conversations/src/utils/cast.dart';

class DetailedDeliveryReceipt {
  DetailedDeliveryReceipt(
    this.conversationSid,
    this.channelMessageSid,
    this.dateCreatedAsDate,
    this.dateUpdatedAsDate,
    this.errorCode,
    this.messageSid,
    this.participantSid,
    this.sid,
  );

  final String conversationSid;
  final String channelMessageSid;
  final String? dateCreatedAsDate;
  final String? dateUpdatedAsDate;
  final int errorCode;
  final String messageSid;
  final String participantSid;
  final String sid;

  factory DetailedDeliveryReceipt.fromPigeon(
    DetailedDeliveryReceiptData deliveryReceiptData,
  ) {
    return DetailedDeliveryReceipt.fromObjectList(
        deliveryReceiptData.encode() as List<Object?>);
  }

  factory DetailedDeliveryReceipt.fromMap(Map<String, dynamic> map) {
    final detailedDeliveryReceipt = DetailedDeliveryReceipt(
      map['conversationSid'],
      map['channelMessageSid'],
      map['dateUpdatedAsDate'],
      map['dateCreatedAsDate'],
      map['errorCode'],
      map['messageSid'],
      map['participantSid'],
      map['sid'],
    );
    return detailedDeliveryReceipt;
  }

  /// Construct from a list of attributes.
  factory DetailedDeliveryReceipt.fromObjectList(List<Object?> attributes) {
    final detailedDeliveryReceipt = DetailedDeliveryReceipt(
      attributes[0] as String,
      attributes[1] as String,
      castString(attributes[2]),
      castString(attributes[3]),
      attributes[4] as int,
      attributes[5] as String,
      attributes[6] as String,
      attributes[7] as String,
    );
    return detailedDeliveryReceipt;
  }

  @override
  String toString() {
    return 'DetailedDeliveryReceipt{sid: $sid, conversationSid: $conversationSid, channelMessageSid: $channelMessageSid, errorCode: $errorCode, messageSid: $messageSid}';
  }
}
