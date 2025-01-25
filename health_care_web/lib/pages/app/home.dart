import 'package:flutter/material.dart';
import 'package:health_care_web/components/drawer/simple_drawer/drawer_index_controller.dart';
import 'package:health_care_web/components/drawer/simple_drawer/simple_drawer.dart';
import 'package:health_care_web/components/top_app_bar/top_app_bar3.dart';
import 'package:health_care_web/pages/app/pages/summary.dart';
import 'package:health_care_web/pages/app/services/auth_service.dart';
import '../../constants/consts.dart';
import 'package:iconly/iconly.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DrawerIndexController drawerIndexController = DrawerIndexController();
  final List<Widget> pages = [
    const Summary(),
    const Text('Test Drawer 2'),
    const Text('Test Drawer 3'),
    const Text('Test Drawer 4'),
    const Text('Test Drawer 5'),
    const Text('Test Drawer 6'),
    const Text('Test Drawer 7'),
  ];
  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);
    return Scaffold(
      backgroundColor: StyleSheet().uiBackground,
      drawer: DrawerFb1(
          title: "Dashboard",
          items: [
            DrawerItems(
                index: 0,
                title: 'Home',
                icon: Icons.home,
                onTap: () {
                  setState(() {
                    drawerIndexController.setSelectedIndex(0);
                  });
                }),
            DrawerItems(
                index: 1,
                title: 'Patients',
                icon: Icons.local_hospital,
                onTap: () {
                  setState(() {
                    drawerIndexController.setSelectedIndex(1);
                  });
                }),
            DrawerItems(
                index: 2,
                title: 'Device Manager',
                icon: Icons.devices_other,
                onTap: () {
                  setState(() {
                    drawerIndexController.setSelectedIndex(2);
                  });
                }),
            DrawerItems(
                index: 3,
                title: '',
                icon: Icons.search,
                onTap: () {
                  setState(() {
                    drawerIndexController.setSelectedIndex(3);
                  });
                }),
            DrawerItems(
                index: 4,
                title: 'Profile',
                icon: Icons.person,
                onTap: () {
                  setState(() {
                    drawerIndexController.setSelectedIndex(4);
                  });
                }),
          ],
          backgroundColor: StyleSheet().uiBackground,
          textColor: StyleSheet().uiBackground,
          titleColor: StyleSheet().btnBackground,
          selectedTextColor: StyleSheet().btnBackground,
          dividerColor: StyleSheet().divider,
          drawerWidth: 350,
          drawerRadius: 10,
          drawerIndexController: drawerIndexController),
      appBar: CustomTopAppBar3(
        title: "Smart Care - Doctor",
        backOnPressed: () {},
        backgroundColor: StyleSheet().topbarBackground,
        titleColor: StyleSheet().topbarText,
        leadingIcon: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(
              Icons.menu,
              color: StyleSheet().topbarText,
            ),
          ),
        ),
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
        child: pages[drawerIndexController.getSelectedIndex()],
      ),
    );
  }
}
