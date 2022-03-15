import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/app/sign_in/sign_in_manager.dart';
import 'package:time_tracker/app/sign_in/sign_in_button.dart';
import 'package:time_tracker/app/sign_in/social_sign_in_button.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key, required this.manager, required this.isLoading})
      : super(key: key); //constructor
  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (context) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (context, isLoading, child) => Provider<SignInManager>(
          create: (context) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
              builder: (context, manager, _) => SignInPage(
                    manager: manager,
                    isLoading: isLoading.value,
                  )),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }
    showExceptionAlertDialog(context,
        title: 'Sign in failed', exception: exception);
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await manager.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } on FirebaseAuthException catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithEmail(BuildContext context) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => EmailSignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Time Tracker',
        ),
        elevation: 2.0,
      ),
      body: _buildContent(context),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context) {
    //isLaoding variable is used to control the spinner
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: _buildHeader(),
            height: 50.0,
          ),
          SizedBox(
            height: 48.0,
          ),
          SocialSignInButton(
              assetName: 'images/google-logo.png',
              text: 'Sign in with Google',
              color: Colors.white,
              textColor: Colors.black87,
              onPressed: isLoading ? null : () => _signInWithGoogle(context)),
          SizedBox(
            height: 8.0,
          ),
          SocialSignInButton(
              assetName: 'images/facebook-logo.png',
              text: 'Sign in with Facebook',
              color: Color(0xFF334D92),
              textColor: Colors.white,
              onPressed: isLoading ? null : () => _signInWithFacebook(context)),
          SizedBox(
            height: 8.0,
          ),
          SignInButton(
              text: 'Sign in with email',
              color: Color(0xFF00796B),
              textColor: Colors.white,
              onPressed: isLoading ? null : () => _signInWithEmail(context)),
          SizedBox(
            height: 8.0,
          ),
          Text(
            'or',
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8.0,
          ),
          SignInButton(
            text: 'Go anonymous',
            color: Color(0xFFDCE775),
            textColor: Colors.black,
            onPressed: isLoading ? null : () => _signInAnonymously(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    //Function that controls the "Sign In header and spinner"
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign In',
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }
}
