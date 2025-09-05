import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inkombe_flutter/homepage.dart';

import '../../widgets.dart';
import '../../widgets/CustomButton.dart';
import '../firebase_auth.dart';

class LoginPage extends StatefulWidget{
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key,
  required this.showRegisterPage,
  }) : super(key:key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
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
                Image.asset(
                    'assets/IDmyCow.png',
                  height: 300,
                  width: 300,

                ),

                const Text(
                  'Hello!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10,),
                const Text(
                  'Welcome Farmer',
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
            
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //  child: GestureDetector(
                //    onTap: ()  {
                //    login();
                //    },
                //    child: Container(
                //      padding: const EdgeInsets.all(20),
                //      decoration: BoxDecoration(
                //          color: Color(0xFF064151),
                //          borderRadius: BorderRadius.circular(12)
                //      ),
                //
                //      child: const Center(
                //        child: Text('Sign In', style: TextStyle(color:Colors.white),
                //        ),
                //      ),
                //    ),
                //  ),
                // ),
                      CustomButton(
                        icon: Icons.exit_to_app,
                        text: 'Sign in',
                        onPressed: (){
                          login();
                        }

                      )
                    ],
                  ),
                ),
                const SizedBox(height:40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member?"),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: const Text(' Register now',
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
  login() async{
    if (formKey.currentState!.validate()){
      // create loader state here
      await _authService.loginWithEmailAndPassword(_emailController.text.trim(),_passwordController.text.trim()).then(
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