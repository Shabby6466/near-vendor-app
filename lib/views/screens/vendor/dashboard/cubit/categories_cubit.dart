import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/categories_service.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await CategoriesService.getCategoriesNames();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
