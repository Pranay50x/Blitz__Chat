import 'package:chat_app/consts.dart';
import 'package:chat_app/services/alert_services.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey <FormState> _loginFormKey= GlobalKey();
  final GetIt getIt = GetIt.instance;
  late AuthService _authService; 
  String? email, password; 
  late NavigationService _navigationService;
  late AlertServices _alertServices; 

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertServices = getIt.get<AlertServices>(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: [_headerText(), _loginForm(), _createAccountLink()],
      ),
    ));
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
            "Hi Welcome Back",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Hello there, sign in to continue',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.4,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFormField(
            onSaved: (value){
              setState(() {
                email = value;
              });
            },
            validationRegexp: EMAIL_VALIDATION_REGEX,
            height: MediaQuery.sizeOf(context).height * 0.1,
            hintText: 'Email',
          ),
          CustomFormField(
            onSaved: (value){
              setState(() {
                password = value;
              });
            },
            obscureText: true,
            validationRegexp: PASSWORD_VALIDATION_REGEX,
            height: MediaQuery.sizeOf(context).height * 0.1,
            hintText: 'Password',
          ),
          _loginButton(),
        ],
      )),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MaterialButton(
        onPressed: () async {
          if(_loginFormKey.currentState?.validate()?? false){
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            print(result);
            if(result){
              _navigationService.pushReplacementNamed("/home");
            }
            else{
              _alertServices.showToast(text: "Failed to Login!, try again later",
              icon: Icons.error); 
            }
          }
        },
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _createAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.white),
          ),
          GestureDetector(
            onTap: (){
              _navigationService.pushNamed("/register");
            },
            child: Text(
              " Sign Up",
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
