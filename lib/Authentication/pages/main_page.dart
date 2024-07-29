import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/Authentication/pages/login.dart';
import 'package:inkombe_flutter/Authentication/pages/login_or_register_switch_page.dart';
import 'package:inkombe_flutter/Authentication/placeholder.dart';
import 'package:inkombe_flutter/homepage.dart';

class MainPageRouter extends StatelessWidget {
  const MainPageRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return const Homepage();
          } else{
            return const LoginOrRegisterSwitchPage();
          }
        },
      )
    );
  }
}
