import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:komutan/app/dashboard/document/document_model.dart';
import 'package:komutan/app/dashboard/document/documents_controller.dart';
import 'package:komutan/app/dashboard/notification/notification_controller.dart';
import 'package:komutan/app/dashboard/notification/notification_screen.dart';
import 'package:komutan/utils/app_colors.dart';

class DocumentsPage extends StatelessWidget {
  final String? shipmentId;

  DocumentsPage({super.key, this.shipmentId});

  late final DocumentsController controller = Get.put(DocumentsController(shipmentId: shipmentId), tag: shipmentId);
  final NotificationController notificationController = Get.isRegistered<NotificationController>() ? Get.find<NotificationController>() : Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
                ),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Get.back();
                  }
                },
              )
            : null,
        title: Center(child: const Text('Documents')),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Get.to(() => const NotificationScreen()),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 38, height: 38, child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 22)),
                  Obx(
                    () => notificationController.unreadCount.value > 0
                        ? Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.documents.isEmpty) {
          return const Center(
            child: Text('No documents found', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.documents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = controller.documents[index];

            return _DocumentCard(doc: doc, onDownload: () => controller.downloadDocument(doc));
          },
        );
      }),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onDownload;

  const _DocumentCard({required this.doc, required this.onDownload});

  IconData _getIcon(DocumentType type) {
    switch (type) {
      case DocumentType.shipment:
        return Icons.inventory_2_outlined;
      case DocumentType.pod:
        return Icons.description_outlined;
      case DocumentType.license:
        return Icons.shield_outlined;
      case DocumentType.insurance:
        return Icons.verified_user_outlined;
      case DocumentType.vehicle:
        return Icons.local_shipping_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color.fromARGB(255, 236, 220, 222), borderRadius: BorderRadius.circular(10)),
            child: Icon(_getIcon(doc.type), color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${doc.subtitle} • ${doc.date}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDownload,
            child: const Icon(Icons.download_outlined, color: AppColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}
