import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello/constants/routes.dart';
import 'package:hello/services/API/api_services.dart';
import 'package:hello/services/auth/block/auth_bloc.dart';
import 'package:hello/services/auth/block/auth_event.dart';
import 'package:hello/services/auth/block/auth_states.dart';
import 'package:hello/services/auth/firebase_auth_provide.dart';
import 'package:hello/views/complaint.dart';

import 'package:hello/views/login_view.dart';

import 'package:hello/views/otp.dart';
import 'package:hello/views/phone.dart';

import 'package:hello/views/register_view.dart';
import 'package:hello/views/verify_email_view.dart';
import 'package:hello/views/vitals.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'Helper/loading/loading.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    //simpleTask will be emitted here.
    // String? id = "VBCR0192105200002";
    if (task == "first") {
      String? tempurature = inputData?['tempurature'].toString();
      String? resprate = inputData?['resprate'].toString();
      String? testdate = inputData?['testdate'].toString();
      String? bloodpres = inputData?['bldpres'].toString();
      String? pulox = inputData?['pulox'].toString();
      String? entrydate = inputData?['entrydate'].toString();
      // String? serno = inputData?['serno'].toString();

      await ApiServices.uploadVitals(
          tempurature: tempurature!,
          resprate: resprate!,
          pulse: pulox!,
          bldPres: bloodpres!,
          entrydate: entrydate!,
          testdate: testdate!);
      print("hiiiiiiiiiiiiiiiiiii");
    } else if (task == "second") {
      String? comp1 = inputData?['comp1'].toString();
      String? comp2 = inputData?['comp2'].toString();
      String? comp3 = inputData?['comp3'].toString();
      String? dur1 = inputData?['dur1'].toString();
      String? dur2 = inputData?['dur2'].toString();
      String? entrydate = inputData?['entrydate'].toString();
      String? dur3 = inputData?['dur3'].toString();
      String? hdmy1 = inputData?['hdmy1'].toString();
      String? hdmy2 = inputData?['hdmy2'].toString();
      String? hdmy3 = inputData?['hdmy3'].toString();
      await ApiServices.uploadComplaint(
          comp1: comp1!,
          comp2: comp2!,
          comp3: comp3!,
          dur1: dur1!,
          dur2: dur2!,
          dur3: dur3!,
          durUnit1: hdmy1!,
          durUnit2: hdmy2!,
          durUnit3: hdmy3!);
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  await Permission.notification.isDenied.then(
    (value) {
      if (value) {
        Permission.notification.request();
      }
    },
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: HomePage(),
      ),
      routes: {
        loginroute: (context) => const LoginView(),
        registerroute: (context) => const RegisterView(),
        notesroute: (context) => const NotesView(),
        myphone: (context) => const MyPhone(),
        myverify: (context) => const MyVerify(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        newComplaintRoute: (context) => const ComplaintView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
      listener: (context, state) {
        if (state.isloading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? "Please wait a moment...");
        } else {
          LoadingScreen().hide();
        }
      },
    );
  }
}
