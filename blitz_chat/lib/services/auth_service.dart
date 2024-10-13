import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseauth = FirebaseAuth.instance;
  User? _user; 
  User? get user{
    return _user; 
  }

  AuthService(){

    _firebaseauth.authStateChanges().listen(authStateChangesStreamListener); 

  }
  Future<bool> login(String email, String password) async{
    try{

      final credential = await _firebaseauth.signInWithEmailAndPassword(email: email, password: password);
      if(credential.user !=null){
        _user= credential.user;
        return true; 
      }
    }
    catch(e){
      print(e);
    }
    return false; 
  }

  Future <bool> signUp(String email, String password) async{
    try {
      final credential  = await _firebaseauth.createUserWithEmailAndPassword(email: email, password: password); 
      if(credential.user!=null){
        _user = credential.user; 
        return true;
      }
      
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> logout() async{
    try{
      await _firebaseauth.signOut();
      return true; 
    }
    catch (e){
      print(e); 
    }
    return false;
  }

  void authStateChangesStreamListener(User? user){
    if(_user!=null){
      _user= user; 
    }
    else{
      _user = null; 
    }
  }
}