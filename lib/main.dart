import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'src/authentication.dart';
import 'src/widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => AplicationState(),
      builder: (context, _) => MyApp(),
    ),

  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter & Firebase',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.deepPurple,
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter & Firebase'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/S.E.Group_logo.png'),
          SizedBox(height: 8,),
          IconAndDetail(Icons.calendar_today, '12 July'),
          IconAndDetail(Icons.location_city, 'Urganch'),
          Consumer<AplicationState>(
            builder: (context, appState, _) => Authentication(
                loginState: appState.loginState,
                email: appState.email!,
                startLoginFlow: appState.startLoginFlow,
                registerAccount: appState.registerAccount,
                signOut: appState.signOut,
                verifyEmail: appState.verifyEmail,
                signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
                cancelRegistration: appState.cancelRegistration
            ),
          ),
          Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          Header("What we\'ll be doing"),
          Paragraph(
            'Join us for a day full of Firebase Workshop and Pizza!',
          ),
        ],
      ),
    );
  }
}


class AplicationState extends ChangeNotifier{
  AplicationState(){
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = AplicationLoginState.loggedIn;
      } else {
        _loginState = AplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
  }

  AplicationLoginState _loginState = AplicationLoginState.loggedOut;
  AplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  void startLoginFlow(){
    _loginState = AplicationLoginState.emailAdres;
    notifyListeners();
  }

  void verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')){
        _loginState = AplicationLoginState.pasword;
      } else{
        _loginState = AplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch(e){
      errorCallback(e);
    }
  }

  void signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCalback,
      ) async {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        } on FirebaseAuthException catch(e) {
          errorCalback(e);
        }
  }

  void cancelRegistration(){
    _loginState = AplicationLoginState.emailAdres;
    notifyListeners();
  }

  void registerAccount(
      String displayName,
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCalback
      ) async {
        try {
          var credintial = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
          await credintial.user!.updateProfile(displayName: displayName);
        } on FirebaseAuthException catch(e){
          errorCalback(e);
        }
  }

  void signOut(){
    FirebaseAuth.instance.signOut();
  }
}