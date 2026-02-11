import 'package:get/get.dart';

import '../../domain/entities/processed_item.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../routes/app_pages.dart';
import '../widgets/capture_sheet.dart';

/// Home: list history, delete, FAB → capture. No setState; all reactive via GetX.
class HomeController extends GetxController {
  HomeController(this._getHistory, this._deleteItem);

  final GetHistoryUseCase _getHistory;
  final DeleteItemUseCase _deleteItem;

  final RxList<ProcessedItem> items = <ProcessedItem>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  @override
  void onReady() {
    loadHistory();
    super.onReady();
  }

  Future<void> loadHistory() async {
    loading.value = true;
    error.value = '';
    try {
      final list = await _getHistory();
      items.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _deleteItem(id);
      items.removeWhere((e) => e.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  void openCapture() {
    Get.bottomSheet(
      const CaptureSheet(),
      isScrollControlled: true,
    );
  }

  void openDetail(String id) {
    Get.toNamed(AppRoutes.detail, arguments: id);
  }
}
