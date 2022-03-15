import 'dart:async';

import 'package:time_tracker/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInBloc {
  EmailSignInBloc({required this.auth});
  final AuthBase auth;
  final StreamController<EmailSignInModel> _modelController =
      StreamController<EmailSignInModel>();
  EmailSignInModel _model = EmailSignInModel();

  Stream<EmailSignInModel> get modelStream => _modelController.stream;
  void dispose() {
    _modelController.close();
  }

  Future<void> sumbit() async {
    // updateWith(submitted: true, isLoading: true);
    try {
      if (_model.formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_model.email, _model.password);
      } else {
        await auth.createUserWithEmailAndPassword(
            _model.email, _model.password);
      }
    } catch (e) {
      // updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateWith({
    String email = '',
    String password = '',
    EmailSignInFormType formType = EmailSignInFormType.signIn,
    bool isLoading = false,
    bool submitted = false,
  }) {
    // print('updateWith : ${email}');
    _model.copyWith(
        email: email,
        password: password,
        formType: formType,
        isLoading: isLoading,
        submitted: submitted);
    _modelController.add(_model);
  }
}
