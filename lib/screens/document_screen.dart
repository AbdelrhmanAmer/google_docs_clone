import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as delta;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colors.dart';
import '../model/error.dart';
import '../model/document.dart' as doc;
import '../common/widgets/loader.dart';
import '../repository/auth_repository.dart';
import '../repository/doc_repository.dart';
import '../repository/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final titleController = TextEditingController(text: 'Untitled Doucment');
  quill.QuillController? _quillController;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    getDocumentData();

    socketRepository.listenChanges((data) {
      _quillController?.compose(
        delta.Delta.fromJson(data['delta']),
        _quillController?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.remote,
      );
    });
  }

  void getDocumentData() async {
    errorModel = await ref
        .read(docRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as doc.Document).title;
      _quillController = quill.QuillController(
        selection: const TextSelection.collapsed(offset: 0),
        document: (errorModel!.data as doc.Document).content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                delta.Delta.fromJson(
                  (errorModel!.data as doc.Document).content,
                ),
              ),
      );
      setState(() {});
    }
    _quillController!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {'delta': event.change, 'room': widget.id};
        socketRepository.typing(map);
      }
    });
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
    _quillController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quillController == null) {
      return const Loader();
    }
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
              controller: _quillController!,
              config: const quill.QuillSimpleToolbarConfig(color: Colors.blue),
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
                      controller: _quillController!,
                      config: const quill.QuillEditorConfig(autoFocus: true),
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
