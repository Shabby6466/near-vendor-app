class User {
  String? _fullName;
  String? _email;
  String? role;
  double? _lastKnownLatitude;
  double? _lastKnownLongitude;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  bool? _mustChangePassword;
  bool? _isActive;
  DateTime? _deletedAt;
  String? _id;
  String? _photoUrl;
  String? _phone;

  String? get id => _id;
  String? get fullName => _fullName;
  String? get email => _email;
  double? get lastKnownLatitude => _lastKnownLatitude;
  double? get lastKnownLongitude => _lastKnownLongitude;
  DateTime? get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;
  bool? get mustChangePassword => _mustChangePassword;
  bool? get isActive => _isActive;
  DateTime? get deletedAt => _deletedAt;
  String? get photoUrl => _photoUrl;
  String? get phone => _phone;

  User({
    String? fullName,
    String? email,
    this.role,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? mustChangePassword,
    bool? isActive,
    DateTime? deletedAt,
    String? id,
    String? photoUrl,
    String? phone,
  }) {
    _id = id;
    _fullName = fullName;
    _email = email;
    _lastKnownLatitude = lastKnownLatitude;
    _lastKnownLongitude = lastKnownLongitude;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _mustChangePassword = mustChangePassword;
    _isActive = isActive;
    _deletedAt = deletedAt;
    _photoUrl = photoUrl;
    _phone = phone;
  }

  User.fromJson(dynamic json) {
    if (json is Map) {
      _id = json['id'] as String?;
      _fullName = json['fullName'] as String?;
      _email = json['email'] as String?;
      role = json['role'] as String?;
      _lastKnownLatitude = json['lastKnownLatitude'] != null
          ? double.tryParse(json['lastKnownLatitude'].toString())
          : (json['latitude'] != null
                ? double.tryParse(json['latitude'].toString())
                : null);
      _lastKnownLongitude = json['lastKnownLongitude'] != null
          ? double.tryParse(json['lastKnownLongitude'].toString())
          : (json['longitude'] != null
                ? double.tryParse(json['longitude'].toString())
                : null);
      _createdAt = json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null;
      _updatedAt = json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null;
      _mustChangePassword = json['mustChangePassword'] as bool?;
      _isActive = json['isActive'] as bool?;
      _deletedAt = json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null;
      _photoUrl = json['photoUrl'] as String?;
      _phone = json['phone'] as String?;
    }
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? mustChangePassword,
    bool? isActive,
    DateTime? deletedAt,
    String? photoUrl,
    String? phone,
    String? cityName,
  }) {
    return User(
      id: id ?? _id,
      fullName: fullName ?? _fullName,
      email: email ?? _email,
      role: role ?? this.role,
      lastKnownLatitude: lastKnownLatitude ?? _lastKnownLatitude,
      lastKnownLongitude: lastKnownLongitude ?? _lastKnownLongitude,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
      mustChangePassword: mustChangePassword ?? _mustChangePassword,
      isActive: isActive ?? _isActive,
      deletedAt: deletedAt ?? _deletedAt,
      photoUrl: photoUrl ?? _photoUrl,
      phone: phone ?? _phone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'fullName': _fullName,
    'email': _email,
    'role': role,
    'lastKnownLatitude': _lastKnownLatitude,
    'lastKnownLongitude': _lastKnownLongitude,
    'createdAt': _createdAt?.toIso8601String(),
    'updatedAt': _updatedAt?.toIso8601String(),
    'mustChangePassword': _mustChangePassword,
    'isActive': _isActive,
    'deletedAt': _deletedAt?.toIso8601String(),
    'photoUrl': _photoUrl,
    'phone': _phone,
  };
}
