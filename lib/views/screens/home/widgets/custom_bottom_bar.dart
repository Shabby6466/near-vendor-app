import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSpacing.screenWidth(context) * 0.56,
        left: AppSpacing.screenWidth(context) * 0.05,
        bottom: AppSpacing.screenHeight(context) * 0.04,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorName.primary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _BottomBarItem(
              isActive: currentIndex == 0,
              icon: Assets.icons.homeIcon.svg(),
              onTap: () => onTap(0),
            ),
            _BottomBarItem(
              isActive: currentIndex == 1,
              icon: Assets.icons.profileIcon.svg(),
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final bool isActive;
  final Widget icon;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(40),
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
              BlendMode.srcIn,
            ),
            child: SizedBox(height: 35, width: 25, child: icon),
          ),
        ),
      ),
    );
  }
}
