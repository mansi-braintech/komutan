import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:komutan/app/dashboard/document/document_model.dart';
import 'package:komutan/data/services/ApiService.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  final String? shipmentId;

  DocumentsController({this.shipmentId});

  final RxList<DocumentModel> documents = <DocumentModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getDocuments();
  }

  Future<void> getDocuments() async {
    try {
      isLoading.value = true;

      final response = await apiService.getMyDocuments(shipmentId: shipmentId);

      debugPrint('Documents API status: ${response.statusCode}');
      debugPrint('Documents API body: ${response.body}');

      if (!response.isOk || response.body == null) {
        Get.snackbar('Error', response.statusText ?? 'Unable to fetch documents', snackPosition: SnackPosition.TOP);
        return;
      }

      final body = response.body;

      if (body is! Map<String, dynamic>) {
        Get.snackbar('Error', 'Invalid documents response', snackPosition: SnackPosition.TOP);
        return;
      }

      final dataObject = body['data'];

      if (dataObject is! Map<String, dynamic>) {
        documents.clear();

        Get.snackbar('Error', 'Documents data not found', snackPosition: SnackPosition.TOP);
        return;
      }

      final getData = dataObject['getData'];

      if (getData is! List) {
        documents.clear();
        return;
      }

      documents.assignAll(
        getData.map<DocumentModel>((item) {
          final json = Map<String, dynamic>.from(item as Map);

          final String source = (json['source'] ?? '').toString().toUpperCase();

          final String type = (json['type'] ?? '').toString().toUpperCase();

          return DocumentModel(
            id: (json['_id'] ?? '').toString(),
            title: (json['title'] ?? 'Document').toString(),
            subtitle: _getSubtitle(source, type),
            date: _formatDate((json['date'] ?? '').toString()),
            type: _getDocumentType(source, type),
            source: source,
            fileName: (json['fileName'] ?? '').toString(),
          );
        }).toList(),
      );

      debugPrint('Documents loaded: ${documents.length}');
    } catch (e, stackTrace) {
      debugPrint('getDocuments error: $e');
      debugPrintStack(stackTrace: stackTrace);

      Get.snackbar('Error', 'Something went wrong while fetching documents', snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  DocumentType _getDocumentType(String source, String type) {
    switch (type) {
      case 'POD':
        return DocumentType.pod;

      case 'LICENSE':
        return DocumentType.license;

      case 'VEHICLE_RC':
        return DocumentType.vehicle;

      case 'INSURANCE':
        return DocumentType.insurance;

      case 'SHIPMENT':
        return DocumentType.shipment;

      default:
        switch (source) {
          case 'POD':
            return DocumentType.pod;

          case 'LICENSE':
            return DocumentType.license;

          case 'FLEET':
            return DocumentType.vehicle;

          default:
            return DocumentType.shipment;
        }
    }
  }

  String _getSubtitle(String source, String type) {
    switch (type) {
      case 'POD':
        return 'POD';

      case 'LICENSE':
        return 'License';

      case 'VEHICLE_RC':
        return 'Vehicle';

      case 'INSURANCE':
        return 'Insurance';

      case 'SHIPMENT':
        return 'Shipment';

      default:
        if (source == 'POD') return 'POD';
        if (source == 'LICENSE') return 'License';
        if (source == 'FLEET') return 'Vehicle';

        return source.isEmpty ? 'Document' : source;
    }
  }

  String _formatDate(String value) {
    try {
      if (value.isEmpty) return '';

      final date = DateTime.parse(value).toLocal();

      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return value;
    }
  }

  Future<void> downloadDocument(DocumentModel doc) async {
    try {
      if (isDownloading.value) return;

      isDownloading.value = true;

      if (doc.id.isEmpty) {
        Get.snackbar('Error', 'Document ID is missing', snackPosition: SnackPosition.TOP);
        return;
      }

      if (doc.fileName.isEmpty) {
        Get.snackbar('Error', 'Document file is missing', snackPosition: SnackPosition.TOP);
        return;
      }

      final response = await apiService.downloadDocument(source: doc.source, id: doc.id, fileName: doc.fileName);

      if (!response.isOk) {
        Get.snackbar('Download Failed', response.statusText ?? 'Unable to download ${doc.title}', snackPosition: SnackPosition.TOP);
        return;
      }

      // `bodyBytes` is a raw Stream<List<int>> (not a plain byte list), so
      // it has to be drained into an actual List<int> before it can be
      // written to disk.
      final bytes = await _collectBytes(response.bodyBytes);

      if (bytes.isEmpty) {
        Get.snackbar('Download Failed', 'Received an empty file for ${doc.title}', snackPosition: SnackPosition.TOP);
        return;
      }

      final savedFile = await _saveToDevice(bytes: bytes, fileName: doc.fileName);

      Get.snackbar(
        'Downloaded',
        '${doc.title} saved to your phone',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => OpenFilex.open(savedFile.path),
          child: const Text(
            'OPEN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Open it right away too, the way delivery apps preview an
      // invoice/receipt the moment it finishes downloading.
      await OpenFilex.open(savedFile.path);
    } catch (e) {
      debugPrint('downloadDocument error: $e');

      Get.snackbar('Download Failed', 'Unable to download ${doc.title}', snackPosition: SnackPosition.TOP);
    } finally {
      isDownloading.value = false;
    }
  }

  /// Drains the raw response stream into a single byte list. Returns an
  /// empty list if there's no stream to read (e.g. an empty body).
  Future<List<int>> _collectBytes(Stream<List<int>>? stream) async {
    if (stream == null) return <int>[];

    final bytes = <int>[];

    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }

    return bytes;
  }

  /// Writes the downloaded bytes to a real file on the device so there's an
  /// actual document the user can reopen or share later, not just an API
  /// call that goes nowhere.
  Future<File> _saveToDevice({required List<int> bytes, required String fileName}) async {
    late final Directory baseDir;

    if (Platform.isAndroid) {
      // App-specific external storage: a real folder on the device's
      // storage that needs no runtime permission, visible via any file
      // manager under Android/data/<package>/files/Documents.
      baseDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      // iOS: the app's Documents directory, visible in the Files app
      // under "On My iPhone" when file sharing is enabled for the app.
      baseDir = await getApplicationDocumentsDirectory();
    }

    final docsDir = Directory('${baseDir.path}/Documents');

    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    final safeName = fileName.trim().isEmpty ? 'document_${DateTime.now().millisecondsSinceEpoch}' : fileName;

    final file = File('${docsDir.path}/$safeName');

    return file.writeAsBytes(bytes, flush: true);
  }
}
