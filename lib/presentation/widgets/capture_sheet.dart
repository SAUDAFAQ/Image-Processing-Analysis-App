import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/errors/app_failure.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/image_source_repository.dart';
import '../../domain/usecases/pick_image_usecase.dart';
import '../../routes/app_pages.dart';

/// Bottom sheet content: Camera / Gallery. Matches reference "Choose Source" modal.
class CaptureSheet extends StatelessWidget {
  const CaptureSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Source',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),
            _SourceTile(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () => _pick(ImageSourceType.camera),
            ),
            const SizedBox(height: 12),
            _SourceTile(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () => _pick(ImageSourceType.gallery),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture Modal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSourceType source) async {
    final useCase = Get.find<PickImageUseCase>();
    try {
      final path = await useCase(source);
      Get.back();
      Get.toNamed(AppRoutes.processing, arguments: path);
    } on PermissionFailure catch (e) {
      Get.snackbar('Permission', e.message);
    } on ImageLoadFailure catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
