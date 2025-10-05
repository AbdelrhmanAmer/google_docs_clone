import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../colors.dart';
import '../model/error.dart';
import '../model/document.dart';
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, // Max width per card
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: snapshot.data!.data.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () => createDocument(context, ref),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 40, color: Colors.blue),
                        ),
                      ),
                    );
                  }

                  // Existing Documents
                  Document document = snapshot.data!.data[index - 1];
                  return GestureDetector(
                    onTap: () => navigateToDocument(document.id),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 32,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            document.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            'Created at: ${_formatDate(document.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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

  String _formatDate(DateTime timestamp) {
    final date = timestamp;
    return '${date.day}/${date.month}/${date.year}';
  }
}
