import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import '../../../../core/extensions/navigation_extensions.dart';


class SplashScreen extends StatefulWidget {
 const SplashScreen({super.key});


 @override
 State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
 @override
 void initState() {
   super.initState();
   Timer(const Duration(seconds: 2), () {
     context.pushNamed(Routes.onBoardingScreen);
   });
 }


 @override
 Widget build(BuildContext context) {
   return const Scaffold(
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           FlutterLogo(size: 100),
           SizedBox(height: 20),
           Text("Splash Screen", style: TextStyle(fontSize: 20)),
         ],
       ),
     ),
   );
 }
}


