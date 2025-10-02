import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/colors.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref){
    ref.read(authRepoProvider.notifier).signOut();
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppbarBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
          IconButton(
            onPressed: () => signOut(ref),
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: Text(
          user == null
              ? 'Null User'
              : 'USER ID: ${user.id}',
        ),
      ),
    );
  }
}
