import 'dart:io';

import 'package:chat_app/consts.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/alert_services.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_services.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email, password,name; 

  late AuthService _authService;

  final GetIt _getIt = GetIt.instance; 

  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  late MediaService _mediaService; 
  late NavigationService _navigationService; 
  late StorageServices _storageServices;
  late DatabaseService _databaseService;
  late AlertServices _alertServices;
  
  bool isLoading = false; 

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>(); 
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageServices = _getIt.get<StorageServices>(); 
    _databaseService = _getIt.get<DatabaseService>();
    _alertServices = _getIt.get<AlertServices>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          children: [
            _headerText(),
            if(!isLoading) _registerForm(),
           if(!isLoading)  _loginAccountLink(),
           if(isLoading) const Expanded( child: Center(
            child: CircularProgressIndicator(),
           ),)
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's Get Started!",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Create an account to continue',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      
      child: Form(
        key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profilePic(),
          CustomFormField(hintText: "Name", height: MediaQuery.sizeOf(context).height *0.1, 
          validationRegexp: NAME_VALIDATION_REGEX, 
          onSaved: (value){
            setState(() {
              name = value; 
            });
          }),
          CustomFormField(hintText: "Email", height: MediaQuery.sizeOf(context).height *0.1, 
          validationRegexp: EMAIL_VALIDATION_REGEX, 
          onSaved: (value){
            setState(() {
              email = value; 
            });
          }), 
          CustomFormField(hintText: "Password", height: MediaQuery.sizeOf(context).height *0.1, 
          validationRegexp: PASSWORD_VALIDATION_REGEX, 
          obscureText: true,
          onSaved: (value){
            setState(() {
              password = value; 
            });
          }), 
          _registerButton()
        ],
      ),
      )
    );
  }

  Widget _profilePic() {
    return GestureDetector(
      onTap: () async{
        File? file = await _mediaService.getImageFromGallery();
        if(file != null){
          setState(() {
            selectedImage = file; 
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.05, //change this to 0,15 for mobile view
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            :  NetworkImage(PLACEHOLDER_PFP),
      ),
    );
  }

  Widget _registerButton(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MaterialButton(
        color: Theme.of(context).primaryColor,
        onPressed: () async{
          setState(() {
            isLoading = true;
          });
          try {
            if((_registerFormKey.currentState?.validate()?? false)&& selectedImage !=null){
              _registerFormKey.currentState?.save();
              bool result = await _authService.signUp(email!, password!); 
              if(result){
                 String? pfpURL = await _storageServices.uploadUserImage(file: selectedImage!, 
                 uid: _authService.user!.uid); 

              if(pfpURL != null){
                await _databaseService.createUserProfile(userProfile: UserProfile(uid: _authService.user!.uid, name: name,
                 pfpURL: pfpURL),
                 );
                 _alertServices.showToast(text: "You have successfully registered", icon: Icons.check);
                 _navigationService.goBack(); 
                 _navigationService.pushReplacementNamed('/home'); 
              }else {
                throw Exception("Upload a pfp and try again"); 
              }
              }
              else{
                throw Exception("Exception occured while registering user");
              } 
              print(result); 
               
            }
          } catch (e) {
            print(e);
            _alertServices.showToast(text: "Failed to register, try again later!", icon: Icons.error); 
          }
          setState(() { 
            isLoading = false;
          });
        },
        child: const Text('Register', style: TextStyle(color: Colors.white),),
      ),
    );
  }

   Widget _loginAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "You already have an account? ",
            style: TextStyle(color: Colors.white),
          ),
          GestureDetector(
            onTap: (){
              _navigationService.goBack();
            },
            child: Text(
              " Login",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900),
            ),
          )
        ],
      ),
    );
  }
}
