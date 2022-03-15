import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_bloc.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker/app/sign_in/validators.dart';
import 'package:time_tracker/common_widgets/form_submit_button.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInFormBlocBased extends StatefulWidget
    with EmailAndPasswordValidators {
  EmailSignInFormBlocBased({Key? key, required this.bloc})
      : super(key: key); //constructor

  final EmailSignInBloc bloc;

  static Widget create(BuildContext context) {
    //Special comment : The BuildContext argument is there based on the tutorial however there is no purpose in this case.
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<EmailSignInBloc>(
      create: (context) => EmailSignInBloc(auth: auth),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<EmailSignInBloc>(
          builder: (context, bloc, _) => EmailSignInFormBlocBased(bloc: bloc)),
    );
  }

  @override
  State<EmailSignInFormBlocBased> createState() =>
      _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

//Method to control the 'Next' button in keyboard
  void _emailEditingComplete(EmailSignInModel model) {
    final newFocus = widget.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sumbit() async {
    try {
      await widget.bloc.sumbit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(context, title: 'Sign in failed', exception: e);
    }
  }

  void _toggleFormType(EmailSignInModel model) {
    widget.bloc.updateWith(
      email: '',
      password: '',
      formType: model.formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn,
      isLoading: false,
      submitted: false,
    );
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren(EmailSignInModel model) {
    final primaryText = model.formType == EmailSignInFormType.signIn
        ? 'Sign In'
        : 'Create an account';
    final secondaryText = model.formType == EmailSignInFormType.signIn
        ? 'Need an account? Register'
        : 'Have an account? Sign in';

    bool submitEnabled = !(model.isLoading) &&
        widget.emailValidator.isValid(model.email) &&
        widget.passwordValidator.isValid(model.password); //From Mixin

    // print('email : ${model.email}');
    // print('password : ${model.password}');

    return [
      _buildEmailTextField(model),
      SizedBox(
        height: 8.0,
      ),
      _buildPasswordTextField(model),
      SizedBox(
        height: 8.0,
      ),
      FormSubmitButton(
        text: primaryText,
        onPressed: submitEnabled ? _sumbit : null,
      ),
      SizedBox(
        height: 8.0,
      ),
      FlatButton(
        child: Text(secondaryText),
        onPressed: !model.isLoading ? () => _toggleFormType(model) : null,
      ),
    ];
  }

  TextField _buildEmailTextField(EmailSignInModel model) {
    bool showErrorText =
        model.submitted && !widget.emailValidator.isValid(model.email);
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'example@example.com',
          errorText: showErrorText ? widget.invalidEmailErrorText : null),
      enabled: model.isLoading == false,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _emailFocusNode,
      onEditingComplete: () => _emailEditingComplete(model),
      onChanged: (email) => widget.bloc.updateWith(
          email:
              email), //to call setState so that the 'Sign In' button enables/disable
    );
  }

  TextField _buildPasswordTextField(EmailSignInModel model) {
    bool showErrorText =
        model.submitted && !widget.passwordValidator.isValid(model.password);
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
          labelText: 'Password',
          errorText: showErrorText ? widget.invalidPasswordErrorText : null),
      enabled: model.isLoading == false,
      obscureText: true, //To make the text look like password
      textInputAction: TextInputAction.done,
      focusNode: _passwordFocusNode,
      onEditingComplete: _sumbit,
      onChanged: (password) => widget.bloc.updateWith(
          password:
              password), //to call setState so that the 'Sign In' button enables/disable
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailSignInModel>(
        stream: widget.bloc.modelStream,
        initialData: EmailSignInModel(),
        builder: (context, snapshot) {
          final EmailSignInModel model = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: _buildChildren(model),
              ),
            ),
          );
        });
  }
}
