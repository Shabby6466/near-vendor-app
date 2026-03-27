import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class VendorStatusResponse extends BaseApiResponse {
  String? vendorStatus;

  VendorStatusResponse({super.status, super.message, this.vendorStatus});

  VendorStatusResponse.fromJson(dynamic json) : super.fromJson(json) {
    if (json is Map) {
      // The user provided example shows "data": "APPROVED"
      vendorStatus = json['data'] as String?;
    }
  }
}
