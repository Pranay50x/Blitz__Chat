import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance; 

  CollectionReference? _usersCollection; 
  CollectionReference? _chatCollection; 

    final GetIt _getIt = GetIt.instance; 

  late AuthService _authService;

  DatabaseService(){
    _setupCollectionReferences(); 
    _authService = _getIt.get<AuthService>();
  }

  void _setupCollectionReferences (){
    _usersCollection = _firebaseFirestore.collection('users').withConverter<UserProfile>(
    fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!,
    ) , 
    toFirestore: (userProfile, _)=> userProfile.toJson(),);

    _chatCollection = _firebaseFirestore.collection('chats').withConverter<Chat>(fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
     toFirestore: (chat, _) => chat.toJson(),);

  }

  Future <void> createUserProfile({required UserProfile userProfile}) async{
    await _usersCollection?.doc(userProfile.uid).set(userProfile); 
  }

  Stream<QuerySnapshot<UserProfile>> getUserPrfile(){

    return _usersCollection?.where("uid", isNotEqualTo: _authService.user!.uid).snapshots() 
    as Stream<QuerySnapshot<UserProfile>>;
  }

  Future <bool> checkChatExists(String uid1, String uid2) async{
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();
    if (result!=null){
      return result.exists;
    }
    return false;
  
  }

  Future <void> createNewChat (String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2); 
    final docRef = _chatCollection!.doc(chatID);
    final chat = Chat(id: chatID, participants: [uid1,uid2], messages: []);

    await docRef.set(chat); 
  }


  Future <void> sendChatMessage (String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2); 
    final docRef = _chatCollection!.doc(chatID);
    await docRef.update({
      "messages": FieldValue.arrayUnion([message.toJson(),
      ]),
    });
  }

  Stream getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatID).snapshots() as Stream<DocumentSnapshot<Chat>>; 
  }
}