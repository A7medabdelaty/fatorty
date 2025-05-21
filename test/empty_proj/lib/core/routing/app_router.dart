import 'package:flutter/material.dart';
import '../routing/routes.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';


class AppRouter {
 Route? generateRoute(RouteSettings settings) {
   switch (settings.name) {
     case Routes.splashScreen:
       return _createRoute(const SplashScreen());
     case Routes.onBoardingScreen:
       return _createRoute(const OnboardingScreen());


     default:
       return null;
   }
 }


 PageRouteBuilder _createRoute(Widget page) {
   return PageRouteBuilder(
     transitionDuration: const Duration(milliseconds: 400),
     pageBuilder: (context, animation, secondaryAnimation) => page,
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
       return FadeTransition(
         opacity: animation,
         child: child,
       );
     },
   );
 }
}
