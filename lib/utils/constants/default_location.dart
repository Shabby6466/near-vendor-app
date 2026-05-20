import 'package:nearvendorapp/models/data_models/app_location.dart';

/// Default map center when no saved location exists (Islamabad area).
class DefaultLocation {
  DefaultLocation._();

  static const double latitude = 33.667306;
  static const double longitude = 73.075177;

  static const AppLocation fallback = AppLocation(
    latitude: latitude,
    longitude: longitude,
  );
}
