import 'package:twilio_conversations/api.dart';

class DeliveryReceipt {
  DeliveryReceipt(
    this.total,
    this.read,
    this.undelivered,
    this.delivered,
    this.failed,
    this.sent,
  );

  final int total;
  final String read;
  final String undelivered;
  final String delivered;
  final String failed;
  final String sent;

  factory DeliveryReceipt.fromPigeon(DeliveryReceiptData deliveryReceiptData) {
    return DeliveryReceipt.fromMap(
        Map<String, dynamic>.from(deliveryReceiptData.encode() as Map));
  }

  factory DeliveryReceipt.fromMap(Map<String, dynamic> map) {
    final deliveryReceipt = DeliveryReceipt(
      map['total'],
      map['read'],
      map['undelivered'],
      map['delivered'],
      map['failed'],
      map['sent'],
    );
    return deliveryReceipt;
  }
}
