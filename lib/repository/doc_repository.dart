import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/model/document.dart';
import 'package:google_docs_clone/model/error.dart';
import 'package:http/http.dart';

final docRepositoryProvider = Provider(
  (ref) => DocRepository(client: Client()),
);

class DocRepository {
  final Client _client;
  DocRepository({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel errorModel = ErrorModel(error: 'Unhandled Error', data: null);

    final res = await _client.post(
      Uri.parse('$host/doc/create'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({'createdAt': DateTime.now().millisecondsSinceEpoch}),
    );

    switch (res.statusCode) {
      case 200:
        final decoded = jsonDecode(res.body);
        final document = Document.fromMap(decoded);
        errorModel = ErrorModel(error: null, data: document);
        break;
      default:
        errorModel = ErrorModel(error: res.body, data: null);
        break;
    }
    return errorModel;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel errorModel = ErrorModel(
      error: 'Error while getting documents',
      data: null,
    );
    try {
      final res = await _client.get(
        Uri.parse('$host/docs/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          List<Document> documents = [];
          final decoded = jsonDecode(res.body);
          for (var doc in decoded) {
            documents.add(Document.fromMap(doc));
          }
          errorModel = ErrorModel(error: null, data: documents);
          break;
        default:
          errorModel = ErrorModel(error: res.body, data: null);
          break;
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    return errorModel;
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel errorModel = ErrorModel(
      error: 'Error while getting document',
      data: null,
    );
    try {
      final res = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          errorModel = ErrorModel(
            error: null,
            data: Document.fromJson(res.body),
          );
          break;
        default:
          throw 'This document is not exists, please create a new one.';
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    return errorModel;
  }

  void updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({'id': id, 'title': title}),
    );
  }
}
