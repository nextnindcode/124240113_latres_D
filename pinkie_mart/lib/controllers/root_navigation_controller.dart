import 'package:get/get.dart';

class RootNavigationController extends GetxController {
  // Variabel reaktif untuk menyimpan tab yang sedang dipilih.
  final RxInt selectedIndex = 0.obs;

  // Mengubah tab yang aktif.
  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
