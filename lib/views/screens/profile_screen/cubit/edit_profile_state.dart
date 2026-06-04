import 'dart:io';
import 'package:equatable/equatable.dart';

enum EditProfileStatus { initial, submitting, success, failure }

class EditProfileState extends Equatable {
  final String fullName;
  final String? photoUrl;
  final File? pickedImage;
  final EditProfileStatus status;
  final String? errorMessage;

  const EditProfileState({
    required this.fullName,
    this.photoUrl,
    this.pickedImage,
    this.status = EditProfileStatus.initial,
    this.errorMessage,
  });

  EditProfileState copyWith({
    String? fullName,
    String? photoUrl,
    File? pickedImage,
    EditProfileStatus? status,
    String? errorMessage,
    bool clearImage = false,
  }) {
    return EditProfileState(
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      pickedImage: clearImage ? null : (pickedImage ?? this.pickedImage),
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        photoUrl,
        pickedImage,
        status,
        errorMessage,
      ];
}
