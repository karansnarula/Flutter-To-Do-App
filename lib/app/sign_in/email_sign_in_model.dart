enum EmailSignInFormType { signIn, register }

class EmailSignInModel {
  final String email;
  final String password;
  final EmailSignInFormType formType;
  final bool isLoading;
  final bool submitted;

  EmailSignInModel(
      {this.email = '',
      this.password = '',
      this.formType = EmailSignInFormType.signIn,
      this.isLoading = false,
      this.submitted = false});

  EmailSignInModel copyWith(
      {String email: '',
      String password = '',
      EmailSignInFormType formType: EmailSignInFormType.signIn,
      bool isLoading: false,
      bool submitted: false}) {
    // print('updateWith : ${email}');
    return EmailSignInModel(
        email: email,
        password: password,
        formType: formType,
        isLoading: isLoading,
        submitted: submitted);
  }
}
