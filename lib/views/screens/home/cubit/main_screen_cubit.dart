import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreenCubit extends Cubit<int> {
  MainScreenCubit(super.initialIndex);

  void switchTab(int index) {
    if (index != state) emit(index);
  }
}
