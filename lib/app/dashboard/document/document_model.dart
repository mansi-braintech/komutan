enum DocumentType { shipment, pod, license, insurance, vehicle }

class DocumentModel {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final DocumentType type;

  // API fields
  final String source;
  final String fileName;

  const DocumentModel({required this.id, required this.title, required this.subtitle, required this.date, required this.type, required this.source, required this.fileName});
}
