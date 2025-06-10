import 'package:flutter/material.dart';
import '../styles/AppColors.dart';
import 'package:flutter/services.dart';

/**
 * https://github.com/DiarIbrahim/ios_style_switch
 */

//ignore: must_be_immutable
class IosSwitch extends StatelessWidget {
  double size;

  //color
  Color activeBackgroundColor;
  Color disableBackgroundColor;

  // main border
  Color activeBorderColor;
  Color disableBorderColor;
  double activeBorderWidth;
  double disableBorderWidth;

  double mainBorderRadiusValue;

// dot
  Color dotActiveColor;
  Color dotdisableColor;

  bool isActive;

  // function
  Function(bool) onChanged;

  // duration
  Duration duration;

  IosSwitch({
    required this.onChanged,
    this.duration = const Duration(milliseconds: 150),
    this.isActive = true,
    this.size = 32,
    this.disableBackgroundColor = const Color.fromARGB(255, 57, 56, 61),
    this.activeBackgroundColor = AppColors.sonareFlashi,
    this.activeBorderColor = Colors.grey,
    this.disableBorderColor = Colors.transparent,
    this.activeBorderWidth = 0,
    this.disableBorderWidth = 1,
    this.mainBorderRadiusValue = 100,
    this.dotActiveColor = Colors.white,
    this.dotdisableColor = Colors.white,
  });
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (co, setstate) {
      return body(setstate);
    });
  }

  body(setstate) {
    return GestureDetector(
      onTap: () {
        setstate(() {
          HapticFeedback.lightImpact();
          isActive = !isActive;
          onChanged.call(isActive);
        });
      },
      child: AnimatedContainer(
        width: size + size * 0.7,
        height: size,
        duration: duration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(mainBorderRadiusValue),
          border: Border.all(
              width: isActive ? activeBorderWidth : disableBorderWidth,
              color: isActive ? activeBorderColor : disableBorderColor),
          color: isActive ? activeBackgroundColor : disableBackgroundColor,
        ),
        child: dot(),
      ),
    );
  }

  dot() {
    return Center(
      child: SizedBox(
        width: size + size * 0.55,
        height: size,
        child: AnimatedAlign(
            duration: duration,
            alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
                duration: duration,
                width: size - 0.15 * size,
                height: size - 0.15 * size,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          spreadRadius: 2,
                          color: isActive
                              ? const Color.fromARGB(255, 189, 189, 189)
                                  .withValues(alpha: 0.1)
                              : const Color.fromARGB(255, 117, 117, 117)
                                  .withValues(alpha: 0.1),
                          offset: Offset(1, 1))
                    ],
                    color: isActive ? dotActiveColor : dotdisableColor,
                    borderRadius:
                        BorderRadius.circular(mainBorderRadiusValue)))),
      ),
    );
  }
}
