import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'allCubits/authCubit/auth_cubit.dart';


bool isWhite = false;



void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();


  runApp(MyApp(prefs: prefs));
}



class MyApp extends StatelessWidget
{
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({ this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create:(context)=>AuthCubit(
              prefs: prefs,
              firebaseFirestore: firebaseFirestore,
              firebaseAuth: FirebaseAuth.instance,
              googleSignIn: GoogleSignIn()
            ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        home: const Scaffold(),
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
      ),
    );
  }
}

