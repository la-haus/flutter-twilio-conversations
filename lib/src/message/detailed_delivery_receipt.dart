import 'package:twilio_conversations/api.dart';

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
  final String dateCreatedAsDate;
  final String dateUpdatedAsDate;
  final int errorCode;
  final String messageSid;
  final String participantSid;
  final String sid;

  factory DetailedDeliveryReceipt.fromPigeon(
      DetailedDeliveryReceiptData deliveryReceiptData,
      ) {
    return DetailedDeliveryReceipt.fromMap(
        Map<String, dynamic>.from(deliveryReceiptData.encode() as Map));
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

  @override
  String toString() {
    return 'DetailedDeliveryReceipt{sid: $sid, conversationSid: $conversationSid, channelMessageSid: $channelMessageSid, errorCode: $errorCode, messageSid: $messageSid}';
  }
}
