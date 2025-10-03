import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/model/document.dart';
import 'package:routemaster/routemaster.dart';

import '../model/error.dart';
import '../colors.dart';
import '../common/widgets/loader.dart';
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
    void navigateToDocument(String id) {
      Routemaster.of(context).push('/document/$id');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppbarBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: FutureBuilder<ErrorModel?>(
        future: ref.watch(docRepositoryProvider).getDocuments(user!.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          return Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 600,
              child: ListView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (ctx, index) {
                  Document document = snapshot.data!.data[index];

                  return InkWell(
                    onTap: () => navigateToDocument(document.id),
                    child: SizedBox(
                      height: 50,
                      child: Card(
                        child: Center(
                          child: Text(
                            document.title,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
