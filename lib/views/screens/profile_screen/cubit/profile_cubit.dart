import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/review_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ReviewServices _reviewServices = ReviewServices();

  String? userName;
  String userLocation = 'Location not set';
  String? photoUrl;
  double discoveryRadius = 10.0;
  bool newOfferAlerts = true;
  bool reviewNotifications = true;
  bool isUploadingImage = false;
  bool isGuest = true;

  ProfileCubit() : super(ProfileInitial()) {
    _loadProfile();
    AppData().userNotifier.addListener(_onProfileChanged);
    AppData().locationNotifier.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (state is ProfileSuccess || state is ProfileFailure) {
      _loadProfile(isInitialLoad: false);
    }
  }

  void _loadProfile({bool isInitialLoad = true}) {
    if (isInitialLoad) {
      emit(ProfileLoading());
      newOfferAlerts = true;
      reviewNotifications = true;
    }

    final user = AppData().currentUser;
    final radius = CurrentUserStorage.getDiscoveryRadius();
    final locationName =
        AppData().locationNotifier.value?.displayLabel ?? 'Location not set';

    userName = user?.fullName;
    userLocation = locationName;
    photoUrl = user?.photoUrl;
    discoveryRadius = radius;
    isGuest = user == null;

    emit(ProfileSuccess());
  }

  Future<void> updateRadius(double radius) async {
    discoveryRadius = radius;
    await CurrentUserStorage.setDiscoveryRadius(radius);
    await AppData().setDiscoveryRadius(radius);
    emit(ProfileSuccess());
  }

  void toggleOfferAlerts(bool value) {
    newOfferAlerts = value;
    emit(ProfileSuccess());
  }

  void toggleReviewNotifications(bool value) {
    reviewNotifications = value;
    _reviewServices.toggleReviewNotifications(value);
    emit(ProfileSuccess());
  }

  @override
  Future<void> close() async {
    AppData().userNotifier.removeListener(_onProfileChanged);
    AppData().locationNotifier.removeListener(_onProfileChanged);
    await super.close();
  }
}
