import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/login_required_bottom_sheet.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Indices that require authentication: Chat (3) and Profile (4)
    const protectedIndices = [3];

    if (protectedIndices.contains(index)) {
      final sessionState = context.read<SessionCubit>().state;
      if (sessionState.status != AuthStatus.authenticated) {
        AppBottomSheet.showBottomSheet(
          context: context,
          child: const LoginRequiredBottomSheet(),
        );
        return;
      }
    }
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: ColorName.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomBarItem(
                isActive: currentIndex == 0,
                icon: Assets.icons.homeIcon.svg(),
                onTap: () => _onItemTapped(context, 0),
              ),
              _BottomBarItem(
                isActive: currentIndex == 1,
                icon: Assets.icons.mapIcon.svg(),
                onTap: () => _onItemTapped(context, 1),
              ),
              const SizedBox(height: 50, width: 50),
              _BottomBarItem(
                isActive: currentIndex == 3,
                icon: const Icon(Icons.chat_bubble_outline),
                onTap: () => _onItemTapped(context, 3),
              ),
              _BottomBarItem(
                isActive: currentIndex == 4,
                icon: Assets.icons.profileIcon.svg(),
                onTap: () => _onItemTapped(context, 4),
              ),
            ],
          ),
        ),
        Positioned(
          top: -30,
          child: InkWell(
            onTap: () => _onItemTapped(context, 2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorName.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentIndex == 2 ? ColorName.secondary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorName.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Assets.icons.searchIcon.svg(),
            ),
          ),
        ),
      ],
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(40),
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isActive ? ColorName.primary : Colors.grey.withValues(alpha: 0.6),
              BlendMode.srcIn,
            ),
            child: SizedBox(height: 30, width: 30, child: icon),
          ),
        ),
      ),
    );
  }
}
