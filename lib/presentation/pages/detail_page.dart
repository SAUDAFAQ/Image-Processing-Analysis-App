import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_pages.dart';
import '../controllers/detail_controller.dart';
import '../widgets/extracted_text_section.dart';

class DetailPage extends GetView<DetailController> {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Detail',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        final item = controller.item.value;
        if (item == null) {
          return const Center(
            child: Text(
              'Item not found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.resultPath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.isDocument
                      ? Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: AppColors.accentPdf,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accentPdfOutline,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'PDF',
                              style: TextStyle(
                                color: AppColors.accentPdfOutline,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.fullImage,
                              arguments: item.resultPath,
                            );
                          },
                          child: Image.file(
                            File(item.resultPath),
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              const SizedBox(height: 24),
              _MetaRow('Type', item.type),
              _MetaRow('Date', '${item.date}'),
              _MetaRow('File size', '${item.fileSizeBytes} bytes'),
            
              if (item.isDocument) ...[
                const SizedBox(height: 24),
                ExtractedTextSection(
                  text: item.ocrText ?? '',
                  searchQuery: controller.searchQuery,
                  onCopy: controller.copyOcrToClipboard,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.openPdf,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open PDF'),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.length > 80 ? '${value.substring(0, 80)}...' : value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
