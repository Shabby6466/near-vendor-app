import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/services/auth_services.dart';

part 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial());

  Future<void> deleteAccount(String password) async {
    if (password.isEmpty) {
      emit(const DeleteAccountFailure('Please enter your password.'));
      return;
    }

    emit(DeleteAccountLoading());

     try {
       final response = await AuthServices().deleteAccount(password);

       if (response.success == true) {
         emit(DeleteAccountSuccess());
       } else {
         emit(
           DeleteAccountFailure(
             response.message ?? 'Failed to delete account. Please try again.',
           ),
         );
       }
     } catch (_) {
       emit(
         const DeleteAccountFailure('Something went wrong. Please try again.'),
       );
     }
  }
}
