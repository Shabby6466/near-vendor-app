import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class MediaServices {
  MediaServices._();

  static Future<String?> uploadImage(File file) async {
    try {
      final String fileName = file.path.split('/').last;
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await Server.post(
        ApiConstants.uploadMedia,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] as String?;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }
}
