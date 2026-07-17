import 'package:get/get.dart';
import 'package:komutan/app/dashboard/document/document_model.dart';

class DocumentsController extends GetxController {
  final RxList<DocumentModel> documents = <DocumentModel>[
    const DocumentModel(
      id: '1',
      title: 'Shipment Invoice - TRP-20260502',
      subtitle: 'Shipment',
      date: '08 May 2026',
      type: DocumentType.shipment,
    ),
    const DocumentModel(
      id: '2',
      title: 'Gate Pass - JNPT Port',
      subtitle: 'Shipment',
      date: '08 May 2026',
      type: DocumentType.shipment,
    ),
    const DocumentModel(
      id: '3',
      title: 'POD - TRP-20260430',
      subtitle: 'POD',
      date: '07 May 2026',
      type: DocumentType.pod,
    ),
    const DocumentModel(
      id: '4',
      title: 'Driving License',
      subtitle: 'License',
      date: '15 Jan 2026',
      type: DocumentType.license,
    ),
    const DocumentModel(
      id: '5',
      title: 'Vehicle Insurance',
      subtitle: 'Insurance',
      date: '01 Feb 2026',
      type: DocumentType.insurance,
    ),
    const DocumentModel(
      id: '6',
      title: 'Vehicle RC Book',
      subtitle: 'Vehicle',
      date: '01 Jan 2026',
      type: DocumentType.vehicle,
    ),
    const DocumentModel(
      id: '7',
      title: 'POD - TRP-20260428',
      subtitle: 'POD',
      date: '28 Apr 2026',
      type: DocumentType.pod,
    ),
  ].obs;

  void downloadDocument(DocumentModel doc) {
    Get.snackbar(
      'Downloading',
      '${doc.title} is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
