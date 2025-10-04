import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/colors.dart';
import 'package:google_docs_clone/model/document.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/repository/doc_repository.dart';

import '../model/error.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final titleController = TextEditingController(text: 'Untitled Doucment');
  final quill.QuillController _quillController = quill.QuillController.basic();
  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
    getDocumentData();
  }

  void getDocumentData() async {
    errorModel = await ref
        .read(docRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as Document).title;
      setState(() {});
    }
  }

  void updateDocTitle(WidgetRef ref, String title) {
    ref
        .read(docRepositoryProvider)
        .updateTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  @override
  void dispose() {
    titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppbarBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/docs-logo.png', height: 35),
            const SizedBox(width: 10),
            SizedBox(
              width: 180,
              height: 35,
              child: TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kButtonColor),
                  ),
                  contentPadding: EdgeInsets.only(left: 10, bottom: 0, top: 0),
                ),
                onSubmitted: (value) => updateDocTitle(ref, value),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {},
              label: const Text('Share', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.lock, color: Colors.white),
            ),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey.shade300),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillSimpleToolbar(
              controller: _quillController,
              config: const quill.QuillSimpleToolbarConfig(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 750,

                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(70),
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                      config: const quill.QuillEditorConfig(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
