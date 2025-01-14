import 'package:flutter/material.dart';
import '../../constants/consts.dart';
import '../../components/bottom_app_bars/bottom_app_bar_1/bottom_navigation_custom1.dart';
import '../../components/bottom_app_bars/bottom_app_bar_1/menuController.dart';
import '../../components/bottom_app_bars/bottom_app_bar_1/bottom_nav_button_1.dart';
import 'package:iconly/iconly.dart';
import '../../components/bottom_app_bars/bottom_app_bar_1/constants1.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> _pages = [
    const Center(child: Text("Home")),
    const Center(child: Text("Search")),
    const Center(child: Text("Profile")),
    const Center(child: Text("Settings")),
  ];
  late final CustomMenuController menuController;

  @override
  void initState() {
    super.initState();
    menuController = CustomMenuController(0, _pages);
  }

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Bottom Navigation Bar 1"),
      ),
      body: Center(
        child: _pages[menuController.getCurrentIndex()],
      ),
      bottomNavigationBar: BottomNavigationCustom1(
        animatedPositionedLeftValue:
            animatedPositionedLeftValueTest(menuController.getCurrentIndex()),
        menuController: menuController,
        navBtnList: [
          BottomNavBtn(
            icon: IconlyLight.home,
            currentIndex: menuController.getCurrentIndex(),
            index: 0,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
          BottomNavBtn(
            icon: IconlyLight.search,
            currentIndex: menuController.getCurrentIndex(),
            index: 1,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
          BottomNavBtn(
            icon: IconlyLight.profile,
            currentIndex: menuController.getCurrentIndex(),
            index: 2,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
          BottomNavBtn(
            icon: IconlyLight.setting,
            currentIndex: menuController.getCurrentIndex(),
            index: 3,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
        ],
      ),
    );
  }
}
