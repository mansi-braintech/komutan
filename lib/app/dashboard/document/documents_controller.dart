import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:komutan/app/dashboard/document/document_model.dart';
import 'package:komutan/data/services/ApiService.dart';

class DocumentsController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

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

      final response = await apiService.getMyDocuments();

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

      await apiService.downloadDocument(source: doc.source, id: doc.id, fileName: doc.fileName);

      Get.snackbar('Success', '${doc.title} downloaded successfully', snackPosition: SnackPosition.TOP);
    } catch (e) {
      debugPrint('downloadDocument error: $e');

      Get.snackbar('Download Failed', 'Unable to download ${doc.title}', snackPosition: SnackPosition.TOP);
    } finally {
      isDownloading.value = false;
    }
  }
}
