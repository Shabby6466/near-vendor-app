class User {
  String? _id;
  String? _address;
  String? _email;

  String? get id => _id;
  String? get address => _address;
  String? get email => _email;

  User({
    String? id,
    String? address,
    String? email,
  }) {
    _id = id;
    _address = address;
    _email = email;
  }

  User.fromJson(dynamic json) {
    if (json is Map) {
      _id = json["id"] as String?;
      _address = json["address"] as String?;
      _email = json["email"] as String?;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map["id"] = _id;
    map["address"] = _address;
    map["email"] = _email;
    return map;
  }
}
