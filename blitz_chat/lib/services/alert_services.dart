import 'package:chat_app/services/navigation_service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

class AlertServices {

  final GetIt getIt = GetIt.instance;

  late NavigationService _navigationService;
  AlertServices(){
    _navigationService = getIt.get<NavigationService>();  
  }

  void showToast({required String text, IconData icon  = Icons.info  }){
    try{
      DelightToastBar(autoDismiss: true, 
      position: DelightSnackbarPosition.top,
      builder: (context){
        return ToastCard(
          leading: Icon(icon, size: 28, color: Colors.red,),
          title: Text(text, 
          style: const TextStyle(
            fontWeight: FontWeight.w700, 
            fontSize: 14),),); 
      }
      ).show(_navigationService.navigatorKey.currentContext!);
    }
    catch(e){
      print(e); 
    }
  }
}