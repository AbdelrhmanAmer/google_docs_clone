import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../colors.dart';
import '../repository/auth_repository.dart';
import '../repository/doc_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepoProvider.notifier).signOut();
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    final token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    debugPrint('\nToken: $token');
    final errorModel = await ref
        .read(docRepositoryProvider)
        .createDocument(token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppbarBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: Text(user == null ? 'Null User' : 'User Email: ${user.email}'),
      ),
    );
  }
}
