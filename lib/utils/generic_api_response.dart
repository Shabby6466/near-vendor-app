import 'package:nearvendorapp/models/api_responses/base_api_response.dart';

class GenericApiResponse extends BaseApiResponse {
  GenericApiResponse({
    super.status,
    super.statusCode,
    super.message,
  });

  GenericApiResponse.fromJson(dynamic json) : super.fromJson(json);
}
