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
    return DeliveryReceipt.fromObjectList(
        deliveryReceiptData.encode() as List<Object?>);
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

  /// Construct from a list of attributes.
  factory DeliveryReceipt.fromObjectList(List<Object?> attributes) {
    final deliveryReceipt = DeliveryReceipt(
      attributes[0] as int,
      attributes[1] as String,
      attributes[2] as String,
      attributes[3] as String,
      attributes[4] as String,
      attributes[5] as String,
    );
    return deliveryReceipt;
  }

  @override
  String toString() {
    return 'DeliveryReceipt{total: $total, read: $read, undelivered: $undelivered, delivered: $delivered, failed: $failed, sent: $sent}';
  }
}
