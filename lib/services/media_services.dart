import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/models/api_responses/media_upload_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class MediaServices {
  MediaServices._();

  static Future<MediaUploadResponse> uploadImage(File file) async {
    try {
      final String fileName = file.path.split('/').last;
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await Server.post(
        ApiConstants.uploadMedia,
        data: formData,
      );
      return MediaUploadResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return MediaUploadResponse(message: e.toString());
    }
  }
}
