import 'package:flutter/material.dart';
import 'package:inkombe_flutter/Authentication/pages/login.dart';
import 'package:inkombe_flutter/Authentication/pages/register_page.dart';

class LoginOrRegisterSwitchPage extends StatefulWidget {
  const LoginOrRegisterSwitchPage({super.key});

  @override
  State<LoginOrRegisterSwitchPage> createState() => _LoginOrRegisterSwitchPageState();
}

class _LoginOrRegisterSwitchPageState extends State<LoginOrRegisterSwitchPage> {
  // show login page by default
  bool showLoginPage = true;

  void switchScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return  LoginPage(showRegisterPage: switchScreens);
    } else{
      return  RegisterPage(showLoginPage: switchScreens);
    }
  }
}
