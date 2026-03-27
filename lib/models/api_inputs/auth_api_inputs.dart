class CreateUserInput{
   CreateUserInput({
     required this.fullName,
     required this.email,
     required this.password,
     required this.latitude,
     required this.longitude,
     required this.role,
   } );

  final String fullName;
  final String email;
  final String password;
  final double latitude;
  final double longitude;
  final UserRoles role;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'latitude': latitude,
      'longitude': longitude,
      'role': role.name,
    };
  }
}

enum UserRoles{
  BUYER,VENDOR,ADMIN
}


class VerifyOtpInput {
  VerifyOtpInput({
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
class LoginInput{

  LoginInput({
    required this.email,
    required this.password,
});

  final String email;
  final String password;

  Map<String,dynamic>toJson(){
    return{
      'email':email,
      'password':password,
    };
  }
}

class ChangePasswordInput {
  ChangePasswordInput({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });

  final String email;
  final String oldPassword;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}

class RegisterInput{

  RegisterInput({
   required this.businessName,
   required this.businessCategory,
   required this.taxId,
   required this.supportContact,
   required this.cnic,
   required this.cnicImageUrl,

});

final String businessName;
final String businessCategory;
final String taxId;
final String supportContact;
final String cnic;
final String cnicImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'businessCategory': businessCategory,
      'taxId': taxId,
      'supportContact': supportContact,
      'cnic': cnic,
      'cnicImageUrl': cnicImageUrl,
    };
  }
}

class UpdateUserInput {
  UpdateUserInput({
    this.fullName,
    this.phone,
    this.photoUrl,
    this.longitude,
    this.latitude,
  });

  final String? fullName;
  final String? phone;
  final String? photoUrl;
  final double? longitude;
  final double? latitude;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (longitude != null) data['longitude'] = longitude;
    if (latitude != null) data['latitude'] = latitude;
    return data;
  }
}