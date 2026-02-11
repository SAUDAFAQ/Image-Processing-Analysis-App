import 'package:get/get.dart';

import 'app_bindings.dart';
import '../presentation/pages/detail_page.dart';
import '../presentation/pages/full_image_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/processing_page.dart';
import '../presentation/pages/result_page.dart';

abstract class AppRoutes {
  static const home = '/';
  static const processing = '/processing';
  static const result = '/result';
  static const detail = '/detail';
  static const fullImage = '/full-image';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.processing,
      page: () => const ProcessingPage(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultPage(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: AppRoutes.fullImage,
      page: () => const FullImagePage(),
    ),
  ];
}
