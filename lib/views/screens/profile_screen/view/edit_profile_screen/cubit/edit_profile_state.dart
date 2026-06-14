import 'dart:io';

import 'package:equatable/equatable.dart';

enum EditProfileStatus { initial, submitting, success, failure }

class EditProfileState extends Equatable {
  final String? photoUrl;
  final File? pickedImage;
  final EditProfileStatus status;
  final String? errorMessage;

  const EditProfileState({
    this.photoUrl,
    this.pickedImage,
    this.status = EditProfileStatus.initial,
    this.errorMessage,
  });

  EditProfileState copyWith({
    String? photoUrl,
    File? pickedImage,
    EditProfileStatus? status,
    String? errorMessage,
    bool clearImage = false,
  }) {
    return EditProfileState(
      photoUrl: photoUrl ?? this.photoUrl,
      pickedImage: clearImage ? null : (pickedImage ?? this.pickedImage),
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [photoUrl, pickedImage, status, errorMessage];
}
