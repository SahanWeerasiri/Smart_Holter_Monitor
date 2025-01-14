import 'package:flutter/material.dart';

class CustomTextInputTypes {
  final String username = "USERNAME";
  final String password = "PASSWORD";
  final String confirmPassword = "CONFIRM_PASSWORD";
  final String text = "TEXT";
}

class CustomColors {
  final Color blueLight = const Color.fromARGB(255, 20, 153, 255);
  final Color blue = const Color.fromARGB(255, 0, 84, 210);
  final Color blueDark = const Color.fromARGB(255, 0, 14, 121);
  final Color blueLighter = const Color.fromARGB(255, 117, 204, 255);

  final Color greyHint = const Color.fromARGB(255, 62, 62, 62);

  final List<Color> gradientForBottomAppBar = [
    const Color.fromARGB(255, 20, 153, 255).withOpacity(0.8),
    const Color.fromARGB(255, 20, 153, 255).withOpacity(0.6),
    const Color.fromARGB(255, 20, 153, 255).withOpacity(0.3),
    Colors.transparent,
  ];
  final Color bottomNavigationColor = const Color.fromARGB(255, 1, 12, 95);
}

class StyleSheet {
  final Color btnBackground = const Color.fromARGB(255, 64, 124, 226);
  final Color btnText = Colors.white;

  final Color elebtnBackground = Colors.white;
  final Color elebtnText = Colors.black;
  final Color elebtnBorder = const Color.fromARGB(255, 163, 163, 163);

  final Color greyHint = const Color.fromARGB(255, 62, 62, 62);
  final Color textBackground = const Color.fromARGB(255, 229, 229, 229);
  final Color text = const Color.fromARGB(255, 64, 124, 226);
  final Color disabledBorder = const Color.fromARGB(255, 135, 135, 135);
  final Color enableBorder = const Color.fromARGB(255, 64, 124, 226);

  final Color titleText = const Color.fromARGB(255, 64, 124, 226);
  final Color titleSupport = const Color.fromARGB(255, 135, 135, 135);

  final Color topbarBackground = Colors.white;
  final Color topbarText = Colors.black;

  final Color divider = const Color.fromARGB(255, 229, 229, 229);

  final uiBackground = Colors.white;

  final List<Color> gradientForBottomAppBar = [
    const Color.fromARGB(255, 0, 170, 255).withOpacity(0.8),
    const Color.fromARGB(255, 0, 170, 255).withOpacity(0.6),
    const Color.fromARGB(255, 0, 170, 255).withOpacity(0.3),
    const Color.fromARGB(255, 0, 170, 255).withOpacity(0.1),
    Colors.transparent,
  ];
  final Color bottomNavigationColor = const Color.fromARGB(255, 64, 124, 226);
  final Color bottomNavigationBase = const Color.fromARGB(255, 0, 170, 255);
  final Color bottomNavigationIcon = const Color.fromARGB(255, 0, 149, 255);
  final Color bottomNavigationShadow = const Color.fromARGB(255, 64, 124, 226);
  final Color bottomNavigationBackground =
      const Color.fromARGB(255, 232, 232, 232);

  final Color currentHeartBox = const Color.fromARGB(255, 180, 216, 255);
  final Color avgHeartBox = const Color.fromARGB(255, 168, 255, 212);
  final Color stateHeartBox = const Color.fromARGB(255, 255, 252, 173);

  final Color chatIcon = const Color.fromARGB(255, 64, 124, 226);
}

class AppSizes {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  void initSizes(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  double getBlockSizeHorizontal(double percentage) {
    return blockSizeHorizontal * percentage;
  }

  double getBlockSizeVertical(double percentage) {
    return blockSizeVertical * percentage;
  }

  double getScreenWidth() {
    return screenWidth;
  }

  double getScreenHeight() {
    return screenHeight;
  }
}

class AnimatedPositionedLeftValue {
  double animatedPositionedLeftValue(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return AppSizes.blockSizeHorizontal * 5.5;
      case 1:
        return AppSizes.blockSizeHorizontal * 22.5;
      case 2:
        return AppSizes.blockSizeHorizontal * 39.4;
      case 3:
        return AppSizes.blockSizeHorizontal * 56.5;
      case 4:
        return AppSizes.blockSizeHorizontal * 73.5;
      default:
        return 0;
    }
  }
}

class DrawerItems {
  final int index;
  final String title;
  final IconData icon;
  final Function() onTap;
  DrawerItems(
      {required this.index,
      required this.title,
      required this.icon,
      required this.onTap});
}
