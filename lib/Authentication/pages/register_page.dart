import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/pages/scan_page.dart';
import 'package:inkombe_flutter/homepage.dart';

import '../../widgets.dart';
import '../firebase_auth.dart';
import '../../services/database_service.dart';


class RegisterPage extends StatefulWidget{
  final VoidCallback showLoginPage;
  const RegisterPage({super.key,
  required this.showLoginPage(),
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  final AuthService _authService = AuthService();
  final formKey = GlobalKey<FormState>();
  // email controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body:  SafeArea(
          child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25,),
                    const Text(
                      'Hello!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color:Colors.grey[200],
                                  border:Border.all(color:Colors.white),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child:  Padding(
                                padding: EdgeInsets.only(left:10.0),
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Email'
                                  ),
                                  validator: (_emailController) {
                                    return RegExp(
                                        "([!#-'*+/-9=?A-Z^-~-]+(.[!#-'*+/-9=?A-Z^-~-]+)*|\"([]!#-[^-~ \t]|(\\[\t -~]))+\")@([!#-'*+/-9=?A-Z^-~-]+(.[!#-'*+/-9=?A-Z^-~-]+)*|[[\t -Z^-~]*])")
                                        .hasMatch(_emailController!)
                                        ? null
                                        : "Please Enter a valid Email";
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color:Colors.grey[200],
                                  border:Border.all(color:Colors.white),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left:10.0),
                                child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration:const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Password'
                                    ),
                                    validator: (_passwordController) {
                                      if (_passwordController!.length < 6) {
                                        return "Password must be at least 6 characters long";
                                      } else {
                                        return null;
                                      }
                                    }
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("By Signing up,"),
                              GestureDetector(
                                onTap: widget.showLoginPage,
                                child: const Text(" I agree to T & C's here",
                                  style: TextStyle(
                                    color:Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: GestureDetector(
                              onTap: ()  {
                                signUp();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Color(0xFFd98f48),
                                    borderRadius: BorderRadius.circular(12)
                                ),

                                child: const Center(
                                  child: Text('Sign Uo', style: TextStyle(color:Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height:10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already a member?"),
                        GestureDetector(
                          onTap: widget.showLoginPage,
                          child: const Text(' Login here',
                            style: TextStyle(
                              color:Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
          ),
        )
    );
  }
  signUp() async{
    if (formKey.currentState!.validate()){
      // create loader state here
      await _authService.signUpUserWithEmailAndPassword(_emailController.text.trim(),_passwordController.text.trim()).then(
              (value) async {
            if (value == true){
              nextScreen(context, const Homepage());
            } else{
              showSnackBar(context, Colors.redAccent, value);
            }
            //   revoke loader state here
          }
      );
    }
  }
}