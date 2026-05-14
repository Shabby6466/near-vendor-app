import 'package:nearvendorapp/models/api_responses/base_api_response.dart';

class GenericApiResponse extends BaseApiResponse {
  GenericApiResponse({super.message, super.status});

  GenericApiResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
