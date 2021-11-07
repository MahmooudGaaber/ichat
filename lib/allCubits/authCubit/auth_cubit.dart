import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allModels/user_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthStates>{
  AuthCubit({
      this.googleSignIn,
      this.firebaseAuth,
      this.firebaseFirestore,
      this.prefs}
      ) : super(AuthInitialState());

  static AuthCubit get(context)=>BlocProvider.of(context);

  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  String getUserFirebaseId(){
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async
  {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if(isLoggedIn && prefs.getString(FirestoreConstants.id)?.isEmpty == true ){
      emit(AuthDoneState());
      return true;
    }
    else {
      emit(AuthCanceledState());
      return false;
    }
  }

  Future<bool>handleSignIn()async
  {
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    emit(AuthLoadingState());
    if(googleUser != null ){
      GoogleSignInAuthentication googleAuth = await googleUser.authentication ;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
       User firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
       if( firebaseUser != null){
         final QuerySnapshot result = await firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .where(FirestoreConstants.id , isEqualTo: firebaseUser.uid )
             .get();
         final List<DocumentSnapshot> document = result.docs;
         if(document.isEmpty){
           firebaseFirestore.collection(FirestoreConstants.pathUserCollection)
               .doc(firebaseUser.uid).set({
             FirestoreConstants.nickname : firebaseUser.displayName,
             FirestoreConstants.photoUrl : firebaseUser.photoURL,
             FirestoreConstants.id : firebaseUser.uid,
             'createdAt':DateTime.now().microsecondsSinceEpoch.toString(),
             FirestoreConstants.chattingWith : null ,
           });

           User currenUser = firebaseUser;
           await prefs.setString(FirestoreConstants.id, currenUser.uid);
           await prefs.setString(FirestoreConstants.nickname, currenUser.displayName?? "");
           await prefs.setString(FirestoreConstants.photoUrl, currenUser.photoURL?? "");
           await prefs.setString(FirestoreConstants.phoneNumber, currenUser.phoneNumber ?? "");
         } else{
           DocumentSnapshot documentSnapshot = document[0];
           UserChat userChat = UserChat.fromDocument(documentSnapshot);

           await prefs.setString(FirestoreConstants.id, userChat.id);
           await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
           await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
           await prefs.setString(FirestoreConstants.phoneNumber, userChat.phoneNumber );
         }
         emit(AuthDoneState());
         return true ;
       } else{
         emit(AuthErrorState());
         return false ;
       }
    } else{
      emit(AuthCanceledState());
      return false ;
    }
  }

  Future<void>handleSignOut() async
  {
    emit(AuthCanceledState());
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

  }
}