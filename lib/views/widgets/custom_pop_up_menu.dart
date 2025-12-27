// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:nearvendorapp/gen/assets.gen.dart';
// import 'package:nearvendorapp/gen/colors.gen.dart';

// class CustomMenuItem {
//   final String label;
//   final SvgGenImage? icon;
//   final Color? textColor;
//   final VoidCallback? onTap;

//   const CustomMenuItem({
//     required this.label,
//     required this.icon,
//     this.textColor,
//     this.onTap,
//   });
// }

// class CustomPopupMenu extends StatefulWidget {
//   final Widget child;
//   final List<CustomMenuItem> menuItems;

//   const CustomPopupMenu({
//     super.key,
//     required this.child,
//     required this.menuItems,
//   });

//   @override
//   State<CustomPopupMenu> createState() => _CustomPopupMenuState();
// }

// class _CustomPopupMenuState extends State<CustomPopupMenu> {
//   final MenuController _menuController = MenuController();
//   final GlobalKey _childKey = GlobalKey();
//   Offset _alignmentOffset = const Offset(-170, 15);
//   AlignmentGeometry _menuAlignment = Alignment.bottomLeft;

//   void _updateMenuPosition() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final RenderBox? renderBox =
//           _childKey.currentContext?.findRenderObject() as RenderBox?;
//       if (renderBox == null) return;

//       final offset = renderBox.localToGlobal(Offset.zero);
//       final size = renderBox.size;
//       final screenSize = MediaQuery.of(context).size;

//       final availableSpaceBelow = screenSize.height - offset.dy - size.height;
//       final availableSpaceAbove = offset.dy;

//       const double itemHeight = 40;
//       const double dividerHeight = 0.4;
//       final double menuHeight =
//           (widget.menuItems.length * itemHeight) +
//           ((widget.menuItems.length - 1) * dividerHeight);

//       setState(() {
//         if (availableSpaceBelow < menuHeight &&
//             availableSpaceAbove > availableSpaceBelow) {
//           _menuAlignment = Alignment.topLeft;
//           _alignmentOffset = Offset(-170, -15 - menuHeight);
//         } else {
//           _menuAlignment = Alignment.bottomLeft;
//           _alignmentOffset = const Offset(-170, 15);
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MenuAnchor(
//       controller: _menuController,
//       alignmentOffset: _alignmentOffset,
//       style: MenuStyle(
//         backgroundColor: WidgetStateProperty.all(Colors.transparent),
//         elevation: WidgetStateProperty.all(0),
//         padding: WidgetStateProperty.all(EdgeInsets.zero),
//         shape: WidgetStateProperty.all(
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
//         ),
//         alignment: _menuAlignment,
//       ),
//       menuChildren: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(22),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 20.1, sigmaY: 20.1),
//             child: Container(
//               width: 197,
//               decoration: BoxDecoration(
//                 color: ColorName.blueShade3.withValues(alpha: 0.28),
//                 borderRadius: BorderRadius.circular(22),
//                 border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: _buildMenuItems(context),
//               ),
//             ),
//           ),
//         ),
//       ],
//       builder: (context, controller, child) {
//         return GestureDetector(
//           onTap: () {
//             if (controller.isOpen) {
//               controller.close();
//             } else {
//               _updateMenuPosition();
//               controller.open();
//             }
//           },
//           child: Container(key: _childKey, child: widget.child),
//         );
//       },
//     );
//   }

//   List<Widget> _buildMenuItems(BuildContext context) {
//     final List<Widget> items = [];

//     for (int i = 0; i < widget.menuItems.length; i++) {
//       final item = widget.menuItems[i];

//       items.add(
//         _buildMenuItem(
//           context,
//           item.label,
//           item.icon,
//           item.textColor ?? Colors.white,
//           onTap: () {
//             item.onTap?.call();
//             _menuController.close();
//           },
//         ),
//       );

//       if (i < widget.menuItems.length - 1) {
//         items.add(_buildDivider());
//       }
//     }

//     return items;
//   }

//   Widget _buildMenuItem(
//     BuildContext context,
//     String text,
//     SvgGenImage? iconPath,
//     Color textColor, {
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 text,
//                 style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                   fontSize: 14,
//                   color: textColor,
//                 ),
//               ),
//             ),
//             iconPath?.svg() ?? const SizedBox(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Container(height: 0.4, color: Colors.white.withValues(alpha: 0.19));
//   }
// }
