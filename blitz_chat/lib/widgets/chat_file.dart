import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {

   final UserProfile userProfile; 
   final Function onTap; 
  const ChatTile({super.key,
  required this.userProfile,
  required this.onTap,
  });

 

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        onTap();
      },
      dense: false, 
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
      ),
      title: Text(userProfile.name!, style: TextStyle(color: Colors.white),), 
    ); 
  }
}