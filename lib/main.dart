import 'package:flutter/material.dart';
import 'package:hello/constants/routes.dart';
import 'package:hello/services/auth/auth_service.dart';
import 'package:hello/views/complaint.dart';

import 'package:hello/views/login_view.dart';

import 'package:hello/views/otp.dart';
import 'package:hello/views/phone.dart';

import 'package:hello/views/register_view.dart';
import 'package:hello/views/verify_email_view.dart';
import 'package:hello/views/vitals.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

Future<void> insertRecord(String name, stytolic, diatolic, uploaded) async {
  try {
    String uri = "http://10.0.2.2/project/insert_record.php";
    await http.post(Uri.parse(uri), body: {
      "name": name,
      "stytolic": stytolic,
      "dytolic": diatolic,
      "uploaded": uploaded,
    });
  } catch (e) {
    print(e);
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    //simpleTask will be emitted here.
    String? name = inputData?['name'].toString();
    String? stytolic = inputData?['stytolic'].toString();
    String? dytolic = inputData?['dytolic'].toString();

    await insertRecord(name!, stytolic!, dytolic!, 'true');
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
      home: const HomePage(),
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
    return FutureBuilder(
      future: Authservice.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = Authservice.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          // final sol = user?.emailVerified ?? false;
          // if (sol) {
          //   print("The User is verified");
          //   return const Text('Done');
          // } else {
          //   print("Not Verified");
          //   return const VerifyEmailView();
          // }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
