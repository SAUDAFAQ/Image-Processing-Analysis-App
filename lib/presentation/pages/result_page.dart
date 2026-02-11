import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/result_controller.dart';
import '../widgets/extracted_text_section.dart';

class ResultPage extends GetView<ResultController> {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              controller.type.value == 'face' ? 'Face Result' : 'PDF Created',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            )),
      ),
      body: Obx(() {
        final isFace = controller.type.value == 'face';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (isFace) _buildFaceComparison(context) else _buildDocPreview(context),
              if (!isFace) ...[
                const SizedBox(height: 24),
                ExtractedTextSection(
                  text: controller.extractedText.value,
                  searchQuery: controller.searchQuery,
                  onCopy: controller.copyOcrToClipboard,
                ),
              ],
              const SizedBox(height: 32),
              if (!isFace) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.openPdf,
                    child: const Text('Open PDF'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.saving.value ? null : controller.done,
                  child: controller.saving.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Text('Done'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFaceComparison(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ImageCard(
            label: 'Before',
            path: controller.originalPath.value,
            placeholder: 'Original',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ImageCard(
            label: 'After',
            path: controller.resultPath.value,
            placeholder: 'B&W',
          ),
        ),
      ],
    );
  }

  Widget _buildDocPreview(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.accentPdf,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentPdfOutline, width: 2),
          ),
          child: const Center(
            child: Text(
              'PDF',
              style: TextStyle(
                color: AppColors.accentPdfOutline,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.title.value.isEmpty ? 'Document Title' : controller.title.value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.label,
    required this.path,
    required this.placeholder,
  });

  final String label;
  final String path;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: path.isNotEmpty && File(path).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        placeholder,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
