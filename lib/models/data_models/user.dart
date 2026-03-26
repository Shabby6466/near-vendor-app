class User {

  String? _fullName;
  String? _email;
  String? _role;
  double? _lastKnownLatitude;
  double? _lastKnownLongitude;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool? _mustChangePassword;
  bool? _isActive;
  DateTime? _deletedAt;
  String? _id;


  String? get id => _id;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  double? get lastKnownLatitude => _lastKnownLatitude;
  double? get lastKnownLongitude => _lastKnownLongitude;
  DateTime? get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;
  bool? get mustChangePassword=> _mustChangePassword;
  bool? get isActive => _isActive;
  DateTime? get deletedAt => _deletedAt;

  User({
    String? fullName,
    String? email,
    String? role,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    DateTime?createdAt,
    DateTime?updatedAt,
    bool?mustChangePassword,
    bool?isActive,
    DateTime?deletedAt,
    String?id,

  }) {
    _id = id;
    _fullName = fullName;
    _email = email;
    _role =role;
    _lastKnownLatitude =lastKnownLatitude;
    _lastKnownLongitude =lastKnownLongitude;
    _createdAt =createdAt;
    _updatedAt =updatedAt;
    _mustChangePassword=mustChangePassword;
    _isActive = isActive;
    _deletedAt = deletedAt;
  }

  User.fromJson(dynamic json) {
    if (json is Map) {
      _id = json["id"] as String?;
      _fullName = json["fullName"] as String?;
      _email = json["email"] as String?;
      _role = json["role"] as String?;
      _lastKnownLatitude = json["lastKnownLatitude"] != null
          ? double.tryParse(json["lastKnownLatitude"].toString())
          : null;
      _lastKnownLongitude = json["lastKnownLongitude"] != null
          ? double.tryParse(json["lastKnownLongitude"].toString())
          : null;
      _createdAt = json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null;
      _updatedAt = json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"].toString()) : null;
      _mustChangePassword = json["mustChangePassword"] as bool?;
      _isActive = json["isActive"] as bool?;
      _deletedAt = json["deletedAt"] != null ? DateTime.tryParse(json["deletedAt"].toString()) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map["id"] = _id;
    map["fullName"] = _fullName;
    map["email"] = _email;
    map["role"] = _role;
    map["lastKnownLatitude"] = _lastKnownLatitude;
    map["lastKnownLongitude"] = _lastKnownLongitude;
    map["createdAt"] = _createdAt?.toIso8601String();
    map["updatedAt"] = _updatedAt?.toIso8601String();
    map["mustChangePassword"] = _mustChangePassword;
    map["isActive"] = _isActive;
    map["deletedAt"] = _deletedAt?.toIso8601String();
    return map;
  }
}
