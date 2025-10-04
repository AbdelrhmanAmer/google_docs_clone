import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/router.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'model/error.dart';
import 'repository/auth_repository.dart';

import 'model/user.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late ErrorModel<User?> errorModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final result = await ref.read(authRepoProvider.notifier).getUserData();

    if (result.data != null) {
      ref.read(userProvider.notifier).state = result.data;
      ref.read(authStatusProvider.notifier).state = AuthStatus.loggedIn;
    } else {
      ref.read(authStatusProvider.notifier).state = AuthStatus.loggedOut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);

    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      title: 'Google Docs Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          switch (authStatus) {
            case AuthStatus.loading:
              return loadingRoute;
            case AuthStatus.loggedIn:
              return loggedInRoute;
            case AuthStatus.loggedOut:
              return loggedOutRoute;
          }
        },
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
