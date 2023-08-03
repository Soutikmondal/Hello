import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello/constants/routes.dart';
import 'package:hello/services/auth/auth_exceptions.dart';
import 'package:hello/services/auth/auth_service.dart';
import 'package:hello/services/auth/block/auth_event.dart';
import '../Utilities/show_error_dialog.dart';
import '../services/auth/block/auth_bloc.dart';
import '../services/auth/block/auth_states.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _pass;

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _pass = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // TODO: implement listener

        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundException) {
            await showErrorDialog(context, 'User Not Found');
          } else if (state.exception is WrongPasswordException) {
            await showErrorDialog(context, 'Wrong Credentials');
          } else if (state.exception is GenericException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Login', style: TextStyle(fontSize: 25)),
            backgroundColor: Color.fromARGB(255, 160, 173, 252),
            centerTitle: true,
          ),
          body: Container(
            color: Color.fromARGB(255, 160, 173, 252),
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'asset/healthcare.png',
                      width: double.infinity,
                      height: 200,
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Email',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Password',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () async {
                            final email = _email.text;
                            final pass = _pass.text;
                            context
                                .read<AuthBloc>()
                                .add(AuthEventLogin(email, pass));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepPurple,
                            onPrimary: Colors.white70,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            minimumSize: Size(150, 20),
                          ),
                          child: const Text('Login',
                              style: TextStyle(fontSize: 15))),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventShouldRegister());
                          },
                          child: const Text("Not registered Yet? Register",
                              style: TextStyle(fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepPurple,
                            onPrimary: Colors.white70,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            minimumSize: Size(180, 50),
                          )),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(myphone);
                            },
                            child: const Text("Register with Phone Number",
                                style: TextStyle(fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurple,
                              onPrimary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              minimumSize: Size(180, 50),
                            )))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
