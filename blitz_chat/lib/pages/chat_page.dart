import 'dart:io';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatUser});

  final UserProfile chatUser; 

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt getIt = GetIt.instance;

  ChatUser? currentUser, otherUser; 
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageServices _storageServices;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _databaseService = getIt.get<DatabaseService>();
    _mediaService = getIt.get<MediaService>();
    _storageServices = getIt.get<StorageServices>();
    currentUser = ChatUser(id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(id: widget.chatUser.uid!, firstName: widget.chatUser.name, profileImage: widget.chatUser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildUI(),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildUI() {
    return StreamBuilder(stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
     builder: (context, snapshot){
      Chat? chat = snapshot.data?.data();
      List <ChatMessage> messages = []; 
      if(chat!=null && chat.messages!=null){
        messages = _generateChatMessages(chat.messages!);
      }
     return DashChat(
      currentUser: currentUser!,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(showOtherUsersName: true, showTime: true),
      inputOptions: InputOptions(
        alwaysShowSend: true,
        trailing: [
          _mediaMessageButton(),
        ],
        inputDecoration: InputDecoration(
          fillColor: Colors.black,
          filled: true,
          hintStyle: TextStyle(color: Colors.white),  // Changed to white
          hintText: "Write a message...",  // Explicitly set the hint text
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputTextStyle: TextStyle(color: Colors.white),
      ),
    );
     });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if(chatMessage.medias?.isNotEmpty ?? false){
      if(chatMessage.medias!.first.type == MediaType.image){
        Message message = Message(senderID: chatMessage.user.id, content: chatMessage.medias!.first.url, 
        messageType:MessageType.Image , sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);
      }
    }
    else{
    Message message = Message(senderID: currentUser!.id,
    content: chatMessage.text,
    messageType: MessageType.Text,
    sentAt: Timestamp.fromDate(chatMessage.createdAt)
    );
    await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);
    }
   
  }

  List<ChatMessage> _generateChatMessages(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if(m.messageType == MessageType.Image){
        return ChatMessage( user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        createdAt: m.sentAt!.toDate(),
        medias: [ChatMedia(url: m.content!, fileName: "", type: MediaType.image)]
        );
      }
      else{
        return ChatMessage(
        user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        createdAt: m.sentAt!.toDate(),
        text: m.content!,
      ); 
      }
      
    }).toList(); 
    chatMessages.sort((a,b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton(){
    return IconButton(onPressed: () async{
     File? file = await _mediaService.getImageFromGallery();
     if(file != null){
      String chatID = generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
     String? downloadURL =  await _storageServices.uploadImageToChat(file: file, chatID: chatID);
     if(downloadURL!=null){
      ChatMessage chatMessage = ChatMessage(
        user: currentUser!,
        createdAt: DateTime.now(),
        medias: [ChatMedia(url: downloadURL, fileName: "", type: MediaType.image)]
      );
      _sendMessage(chatMessage);
     }
     }
    }, icon: Icon(Icons.image,
    color: Colors.tealAccent,));
  }
}