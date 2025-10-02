import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/router.dart';
import 'package:routemaster/routemaster.dart';

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
    errorModel = await ref.read(authRepoProvider.notifier).getUserData();

    if (errorModel.data != null) {
      ref.read(userProvider.notifier).state = errorModel.data;
      debugPrint("\nRestored user: ${errorModel.data!.email}");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final user = ref.watch(userProvider);

    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          if (user != null && user.token.isNotEmpty) {
            debugPrint("\n✅ Logged in as: ${user.email}");
            return loggedInRoute;
          } else {
            debugPrint("\n🚪 Not logged in, showing loggedOutRoute");
            return loggedOutRoute;
          }
        },
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
