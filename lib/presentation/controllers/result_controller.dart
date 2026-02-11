import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/storage_service.dart';
import '../../domain/entities/processed_item.dart';
import '../../domain/usecases/save_metadata_usecase.dart';
import '../../routes/app_pages.dart';
import 'processing_controller.dart';

/// Result: show before/after or PDF; Done saves metadata and goes back to home.
class ResultController extends GetxController {
  ResultController(this._saveMetadata, this._storage);

  final SaveMetadataUseCase _saveMetadata;
  final StorageService _storage;

  final RxString type = 'face'.obs;
  final RxString originalPath = ''.obs;
  final RxString resultPath = ''.obs;
  final RxString title = ''.obs;
  final RxString extractedText = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool saving = false.obs;

  void copyOcrToClipboard() {
    if (extractedText.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: extractedText.value));
    Get.snackbar('', 'Copied to clipboard');
  }

  @override
  void onReady() {
    final args = Get.arguments as ResultArgs?;
    if (args != null) {
      type.value = args.type;
      originalPath.value = args.originalPath;
      resultPath.value = args.resultPath;
      title.value = args.title ?? '';
      extractedText.value = args.extractedText ?? '';
    }
    super.onReady();
  }

  Future<void> openPdf() async {
    if (type.value != 'document' || resultPath.value.isEmpty) return;
    final file = File(resultPath.value);
    if (!file.existsSync()) {
      Get.snackbar('Error', 'File not found');
      return;
    }
    await OpenFilex.open(resultPath.value);
  }

  Future<void> done() async {
    saving.value = true;
    try {
      final size = await _storage.fileSize(resultPath.value);
      final item = ProcessedItem(
        id: const Uuid().v4(),
        originalPath: originalPath.value,
        resultPath: resultPath.value,
        type: type.value,
        date: DateTime.now(),
        fileSizeBytes: size,
        title: title.value.isEmpty ? null : title.value,
        ocrText: type.value == 'PDF Document' ? (extractedText.value.isEmpty ? null : extractedText.value) : null,
      );
      await _saveMetadata(item);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    } finally {
      saving.value = false;
    }
  }
}
