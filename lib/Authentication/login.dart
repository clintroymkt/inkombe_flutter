import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/home.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key:key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{


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
                  'Welcome Farmer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color:Colors.grey[200],
                      border:Border.all(color:Colors.white),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left:10.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email'
                        )
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
                    child: const Padding(
                      padding: EdgeInsets.only(left:10.0),
                      child: TextField(
                        obscureText: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password'
                          )
                      ),
                    ),
                  ),
                ),
                const SizedBox(height:10),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                 child: GestureDetector(
                   onTap: () {
                     Navigator.push(
                         context,MaterialPageRoute(builder: (context) => const Home())
                     );
                   },
                   child: Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                         color: Color(0xFFd98f48),
                         borderRadius: BorderRadius.circular(12)
                     ),

                     child: const Center(
                       child: Text('Sign In', style: TextStyle(color:Colors.white),
                       ),
                     ),
                   ),
                 ),
                ),
                const SizedBox(height:10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a member?"),
                    Text(' Register now',
                      style: TextStyle(
                        color:Colors.blue,
                        fontWeight: FontWeight.bold,
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
}