import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../domain/entities/processed_item.dart';
import '../../domain/usecases/get_item_by_id_usecase.dart';

/// Detail: show full metadata; Open PDF opens file externally.
class DetailController extends GetxController {
  DetailController(this._getItemById);

  final GetItemByIdUseCase _getItemById;

  final Rx<ProcessedItem?> item = Rx<ProcessedItem?>(null);
  final RxBool loading = true.obs;
  final RxString searchQuery = ''.obs;

  void copyOcrToClipboard() {
    final t = item.value?.ocrText ?? '';
    if (t.isEmpty) return;
    Clipboard.setData(ClipboardData(text: t));
    Get.snackbar('', 'Copied to clipboard');
  }

  @override
  void onReady() {
    final id = Get.arguments as String?;
    if (id != null) loadItem(id);
    super.onReady();
  }

  Future<void> loadItem(String id) async {
    loading.value = true;
    try {
      item.value = await _getItemById(id);
    } finally {
      loading.value = false;
    }
  }

  Future<void> openPdf() async {
    final p = item.value?.resultPath;
    if (p == null || p.isEmpty) return;
    final file = File(p);
    if (!await file.exists()) {
      Get.snackbar('Error', 'File not found');
      return;
    }
    await OpenFilex.open(p);
  }
}
