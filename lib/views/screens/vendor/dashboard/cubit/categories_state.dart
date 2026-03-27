abstract class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<String> categories;
  const CategoriesLoaded(this.categories);
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
}
