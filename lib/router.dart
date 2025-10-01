import 'package:flutter/material.dart';
import 'package:google_docs_clone/screens/home_screen.dart';
import 'package:google_docs_clone/screens/login_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => MaterialPage(child: LoginScreen())
});
final loggedInRoute = RouteMap(routes: {
  '/': (route) => MaterialPage(child: HomeScreen())
});