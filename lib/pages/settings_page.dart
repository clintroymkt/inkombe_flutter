import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_circle),
                          Text("Your Account", style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold
                          ),)
                        ],
                      )
                    ],
                  ),
                )
              ],
          ),
        ),
      ))
    );
  }
}
