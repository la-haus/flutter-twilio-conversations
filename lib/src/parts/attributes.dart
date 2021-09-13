import 'dart:convert';

enum AttributesType {
  OBJECT,
  ARRAY,
  STRING,
  NUMBER,
  BOOLEAN,
  NULL,
}

class Attributes {
  //#region Private API properties
  final AttributesType _type;

  final String _json;
  //#endregion

  /// Returns attributes type
  AttributesType get type => _type;

  Attributes(this._type, this._json)
      : assert(_type != null),
        assert(_json != null);

  factory Attributes.fromJson(Map<String, dynamic> map) {
    var type = AttributesType.values.firstWhere((type) {
      return type.toString().split('.')[1] == (map['type']);
    }, orElse: () => null);
    var json = map['data'];
    return Attributes(type, json.toString());
  }

  String toJson() {
    return _json;
  }

  Map<String, dynamic> getJSONObject() {
    if (type != AttributesType.OBJECT) {
      return null;
    } else {
      return jsonDecode(_json) as Map<String, dynamic>;
    }
  }

  List<Map<String, dynamic>> getJSONArray() {
    if (type != AttributesType.ARRAY) {
      return null;
    } else {
      return List<Map<String, dynamic>>.from(jsonDecode(_json) as List);
    }
  }

  String getString() {
    if (type != AttributesType.STRING) {
      return null;
    } else {
      return _json;
    }
  }

  num getNumber() {
    if (type != AttributesType.NUMBER) {
      return null;
    } else {
      return num.tryParse(_json);
    }
  }

  bool getBoolean() {
    if (type != AttributesType.BOOLEAN) {
      return null;
    } else {
      return _json == 'true';
    }
  }
}
