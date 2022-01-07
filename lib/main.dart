import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'weight.dart';

UserCredential? user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'WeighIN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isAuthenticating = false;

  // Method to anonymously authenticate user
  void authenticate(BuildContext context) async {
    setState(() {
      isAuthenticating = true;
    });
    user = await auth.signInAnonymously();
    if (user != null && user!.user!.isAnonymous) {
      isAuthenticating = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SecondPage(
                  title: user!.user!.uid,
                )),
      );
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // authenticate(context);
    return !isAuthenticating
        ? Scaffold(
            backgroundColor: Colors.amber,
            body: Center(
              child: ElevatedButton(
                child: const Text("Login"),
                onPressed: () => authenticate(context),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.amber,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Please wait...',
                  ),
                  Text(
                    'Logging in',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
  }
}
