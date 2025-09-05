import 'package:flutter/material.dart';

import '../Authentication/firebase_auth.dart';
import '../Authentication/pages/login.dart';
import '../widgets.dart';
import '../widgets/alert_dialog.dart';
import '../widgets/settings_option.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
              children: [
                Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_circle),
                        Text("Your Account", style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    // Email
                    SettingOptions(
                      text: 'Email',
                      onPressed: (){},

                    ),
                    const SizedBox(height: 2,),
                    SettingOptions(
                      text: 'Username',
                      onPressed: (){},

                    ),
                    const SizedBox(height: 2,),
                    SettingOptions(
                      text: 'Full name',
                      onPressed: (){},

                    ),

                    SizedBox(height: 30,),
                    SettingOptions(
                      text: 'Notifications',
                      onPressed: (){},

                    ),
                    const SizedBox(height: 2,),
                    SettingOptions(
                      text: 'Share App',
                      onPressed: (){},

                    ),

                    const SizedBox(height: 30,),
                    SettingOptions(
                      text: 'Rate Us',
                      onPressed: (){},

                    ),
                    const SizedBox(height: 2,),
                    SettingOptions(
                      text: 'Privacy policy',
                      onPressed: (){},

                    ),

                    const SizedBox(height: 2,),
                    SettingOptions(
                      text: 'Terms of use',
                      onPressed: (){},

                    ),

                    const SizedBox(height: 2,),
                    SettingOptions(
                      text: 'Contact us',
                      onPressed: (){},

                    ),


                    const SizedBox(height: 30,),
                    SettingOptions(
                      text: 'Change password',
                      onPressed: (){},

                    ),


                    const SizedBox(height: 30,),
                    SettingOptions(
                      text: 'Log out',
                      dialog:
                        CustomAlertDialog(
                          title: 'Warning',
                          content: 'Are you sure you want to log out?',
                          acceptText: 'Yes',
                          rejectText: 'No',
                          onAccept: () {
                            Navigator.pop(context);
                            _authService.signOutUser();
                            nextScreenReplace(context, LoginPage(showRegisterPage: () {  },));
                          },
                          onReject: () {
                            Navigator.pop(context);
                          }
                        ),

                      textColor: Colors.red,
                      backgroundColor: Colors.red,
                    ),

                  ],
                )
              ],
          ),
        ),
      ))
    );
  }
}
