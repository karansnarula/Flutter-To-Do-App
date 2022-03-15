import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:time_tracker/services/auth.dart';

class SignInManager {
  SignInManager({required this.auth, required this.isLoading});
  final AuthBase auth;
  final ValueNotifier<bool> isLoading;

  //Bloc Style Code

  // final StreamController<bool> _isLoadingController = StreamController<bool>();

  // Stream<bool> get isLoadingStream => _isLoadingController.stream;

  // void dispose() {
  //   _isLoadingController.close();
  // }

  // void _setIsLoading(bool isLoading) => _isLoadingController.add(isLoading);

  Future<User?> _signIn(Future<User?> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      isLoading.value = false;
      rethrow; //Rethrow is used for partially handling an exception while allowing it to propagate further.
    }
  }

  Future<User?> signInAnonymously() async =>
      await _signIn(auth.signInAnonymously);
  Future<User?> signInWithGoogle() async =>
      await _signIn(auth.signInWithGoogle);
  Future<User?> signInWithFacebook() async =>
      await _signIn(auth.signInWithFacebook);
}
