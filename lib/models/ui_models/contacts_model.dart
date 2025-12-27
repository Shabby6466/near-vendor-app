class ContactsModel {
  String name;
  String address;
  String? note;

  ContactsModel({
    required this.name,
    required this.address,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'note': note,
    };
  }

  factory ContactsModel.fromJson(Map<String, dynamic> json) {
    return ContactsModel(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactsModel &&
        other.name == name &&
        other.address == address &&
        other.note == note;
  }

  @override
  int get hashCode => name.hashCode ^ address.hashCode ^ note.hashCode;

  @override
  String toString() {
    return 'ContactsModel(name: $name, address: $address, note: $note)';
  }
}
