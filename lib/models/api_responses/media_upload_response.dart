import 'package:nearvendorapp/models/api_responses/base_api_response.dart';

class MediaUploadResponse extends BaseApiResponse {
  String? url;

  MediaUploadResponse({
    super.message,
    super.status,
    this.url,
  });

  MediaUploadResponse.fromJson(dynamic json) : super.fromJson(json) {
    if (json is Map) {
      // Check top level
      url = json['url'] as String? ?? json['path'] as String?;
      
      // Check 'data' field
      if (url == null && json['data'] != null) {
        final data = json['data'];
        if (data is Map) {
          url = data['url'] as String? ?? data['path'] as String?;
        } else if (data is String) {
          url = data;
        }
      }

      // Check 'results' field
      if (url == null && json['results'] != null) {
        final results = json['results'];
        if (results is Map) {
          url = results['url'] as String? ?? results['path'] as String?;
        }
      }
    }
  }
}
