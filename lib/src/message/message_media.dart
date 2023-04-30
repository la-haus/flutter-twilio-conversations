import 'package:twilio_conversations/src/utils/cast.dart';

class MessageMedia {
  final String _sid;
  final String? _fileName;
  final String? _type;
  final int _size;

  //#region Public API properties
  /// Get SID of media stream.
  String get sid {
    return _sid;
  }

  /// Get file name of media stream.
  String? get fileName {
    return _fileName;
  }

  /// Get mime-type of media stream.
  String? get type {
    return _type;
  }

  /// Get size of media stream.
  int get size {
    return _size;
  }

  //#endregion

  MessageMedia(
    this._sid,
    this._fileName,
    this._type,
    this._size,
  );

  /// Construct from a map.
  factory MessageMedia.fromMap(Map<String, dynamic> map) {
    return MessageMedia(
      map['sid'],
      map['fileName'],
      map['type'],
      map['size'],
    );
  }

  /// Construct from a list of attributes.
  factory MessageMedia.fromObjectList(List<Object?> attributes) {
    return MessageMedia(
      attributes[0] as String,
      castString(attributes[1]),
      castString(attributes[2]),
      attributes[3] as int,
    );
  }
}
