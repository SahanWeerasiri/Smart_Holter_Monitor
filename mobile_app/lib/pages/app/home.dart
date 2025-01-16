import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care/components/top_app_bar/top_app_bar2.dart';
import 'package:health_care/pages/app/pages/chat_screen.dart';
import 'package:health_care/pages/app/pages/profile.dart';
import 'package:health_care/pages/app/pages/report_list.dart';
import 'package:health_care/pages/app/pages/summary.dart';
import 'package:health_care/pages/app/services/auth_service.dart';
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
    const Center(child: Summary()),
    const Center(child: ReportList()),
    const Center(child: ChatScreen()),
    Center(child: Profile(user: FirebaseAuth.instance.currentUser)),
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
      backgroundColor: StyleSheet().uiBackground,
      appBar: CustomTopAppBar2(
        title: "Smart Care",
        backOnPressed: () {},
        backgroundColor: StyleSheet().topbarBackground,
        titleColor: StyleSheet().topbarText,
        actions: [
          IconButton(
            icon: Icon(
              IconlyLight.logout,
              color: StyleSheet().topbarText,
            ),
            color: StyleSheet().topbarText,
            onPressed: () {
              AuthService().signout();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logout Successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Center(
        child: _pages[menuController.getCurrentIndex()],
      ),
      bottomNavigationBar: BottomNavigationCustom1(
        backgroundColor: StyleSheet().bottomNavigationBackground,
        baseColor: StyleSheet().bottomNavigationBase,
        gradient: StyleSheet().gradientForBottomAppBar,
        animatedPositionedLeftValue:
            animatedPositionedLeftValueTest(menuController.getCurrentIndex()),
        menuController: menuController,
        navBtnList: [
          BottomNavBtn(
            icon: IconlyLight.home,
            currentIndex: menuController.getCurrentIndex(),
            index: 0,
            iconColor: StyleSheet().bottomNavigationIcon,
            shadowColor: StyleSheet().bottomNavigationShadow,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
          BottomNavBtn(
            icon: IconlyLight.document,
            iconColor: StyleSheet().bottomNavigationIcon,
            shadowColor: StyleSheet().bottomNavigationShadow,
            currentIndex: menuController.getCurrentIndex(),
            index: 1,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
          BottomNavBtn(
            icon: IconlyLight.chat,
            iconColor: StyleSheet().bottomNavigationIcon,
            shadowColor: StyleSheet().bottomNavigationShadow,
            currentIndex: menuController.getCurrentIndex(),
            index: 2,
            onPressed: (val) {
              setState(() {
                menuController.setCurrentIndex(val);
              });
            },
          ),
          BottomNavBtn(
            icon: IconlyLight.profile,
            iconColor: StyleSheet().bottomNavigationIcon,
            shadowColor: StyleSheet().bottomNavigationShadow,
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
