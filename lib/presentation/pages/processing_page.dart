import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/processing_controller.dart';

class ProcessingPage extends GetView<ProcessingController> {
  const ProcessingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final path = Get.arguments as String? ?? '';
    if (path.isNotEmpty && controller.imagePath.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.start(path);
      });
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Processing',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Obx(() {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: controller.imagePath.value.isNotEmpty
                        ? Image.file(
                            File(controller.imagePath.value),
                            height: 160,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(
                            height: 160,
                            width: 160,
                            child: Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Processing...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.progress.value,
                    backgroundColor: AppColors.progressTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.progressMessage.value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (controller.error.value.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    controller.error.value,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Processing Screen',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
