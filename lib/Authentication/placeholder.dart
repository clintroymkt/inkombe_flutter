import 'package:flutter/material.dart';
import 'package:inkombe_flutter/Authentication/firebase_auth.dart';
import 'package:inkombe_flutter/Authentication/pages/main_page.dart';

import '../widgets.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return  Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("wtf"),
              MaterialButton(
                  child: const Text("sign out"),
                  onPressed: () async{
                await _authService.signOutUser();
                nextScreenReplace(context, const MainPageRouter());
              })
            ],
          ),
        ),
      )
    );
  }
}
