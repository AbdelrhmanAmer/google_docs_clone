import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';

import 'model/error.dart';
import 'repository/auth_repository.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepoProvider.notifier).getUserData();
    print(
      "\n\n Error Model: $errorModel  Data: ${errorModel.data ?? errorModel.data}\n",
    );
    if (errorModel.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    print('\n\n******* User: $user **** \n\n');
    return GetMaterialApp(
      initialRoute: '/LoginScreen',
      getPages: [
        GetPage(name: '/LoginScreen', page: () => LoginScreen()),
        GetPage(name: '/HomeScreen', page: () => HomeScreen()),
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: user == null ? LoginScreen() : HomeScreen(),
    );
  }
}
