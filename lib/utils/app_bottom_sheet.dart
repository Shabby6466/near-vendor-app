// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:nearvendorapp/gen/colors.gen.dart';
// import 'package:nearvendorapp/utils/app_navigation.dart';
// import 'package:nearvendorapp/utils/app_spacing.dart';

// class AppBottomSheet {
//   AppBottomSheet._();

//   static Future<T?> showBottomSheet<T>({
//     required BuildContext context,
//     required Widget child,
//     bool isDismissible = true,
//     EdgeInsets padding = const EdgeInsets.all(24),
//     bool isScrollControlled = false,
//   }) {
//     return showModalBottomSheet<T>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isDismissible: isDismissible,
//       useSafeArea: true,
//       enableDrag: isDismissible,
//       isScrollControlled: isScrollControlled,
//       builder: (context) => ClipRRect(
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20.1, sigmaY: 20.1),
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               padding: padding,
//               decoration: BoxDecoration(
//                 color: ColorName.blueShade3.withValues(alpha: 0.7),
//                 gradient: LinearGradient(
//                   colors: [
//                     ColorName.gradientLightBlue2.withValues(alpha: 0.9),
//                     ColorName.gradientDarkBlue2.withValues(alpha: 0.6),
//                   ],
//                   stops: const [0.0, 0.4],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(22),
//                 ),
//                 border: Border.all(
//                   color: Colors.white.withValues(alpha: 0.19),
//                 ),
//               ),
//               child: AnimatedPadding(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeOut,
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom,
//                 ),

//                 child: child,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   static Future<T?> showScrollableBottomSheet<T>({
//     required BuildContext context,
//     double minChildSize = 0.8,
//     Widget Function(BuildContext context, ScrollController scrollController)? builder,
//     bool isDismissible = true,
//     bool showScrollHandle = true,
//   }) {
//     return showModalBottomSheet<T>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isDismissible: isDismissible,
//       isScrollControlled: true,
//       useSafeArea: true,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: DraggableScrollableSheet(
//             initialChildSize: minChildSize + 0.1,
//             minChildSize: minChildSize,
//             expand: false,
//             builder: (_, scrollController) {
//               return ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(22),
//                 ),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 20.1, sigmaY: 20.1),
//                   child: Material(
//                     color: Colors.transparent,

//                     child: Container(
//                       padding: showScrollHandle
//                           ? EdgeInsets.symmetric(
//                               vertical: AppSpacing.mediumVerticalSpacing(
//                                 context,
//                               ),
//                             )
//                           : EdgeInsets.zero,
//                       decoration: BoxDecoration(
//                         color: ColorName.blueShade3.withValues(alpha: 0.7),
//                         gradient: LinearGradient(
//                           colors: [
//                             ColorName.gradientLightBlue2.withValues(alpha: 0.9),
//                             ColorName.gradientDarkBlue2.withValues(alpha: 0.6),
//                           ],
//                           stops: const [0.0, 0.4],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(22),
//                         ),
//                         border: Border.all(
//                           color: Colors.white.withValues(alpha: 0.19),
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (showScrollHandle)
//                             Container(
//                               height: 6,
//                               width: MediaQuery.of(context).size.width * 0.1,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 color: Colors.white.withValues(alpha: 0.3),
//                               ),
//                             ),
//                           if (builder != null) Flexible(child: builder(context, scrollController)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   static Future<void> showConfirmationBottomSheet({
//     required BuildContext context,
//     required String title,
//     String subtitle = '',
//     String message = '',
//     String confirmButtonText = 'Continue',
//     String cancelButtonText = 'Cancel',
//     VoidCallback? onConfirm,
//     VoidCallback? onCancel,
//     Color? confirmButtonColor,
//   }) {
//     return showBottomSheet(
//       context: context,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(
//             height: AppSpacing.mediumVerticalSpacing(context),
//           ),
//           Text(
//             subtitle,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w500,
//               fontSize: 20,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(
//             height: AppSpacing.mediumVerticalSpacing(context),
//           ),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           SizedBox(
//             height: AppSpacing.mediumVerticalSpacing(context),
//           ),
//           ElevatedButton(
//             onPressed: onConfirm,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: confirmButtonColor,
//             ),
//             child: Text(confirmButtonText),
//           ),
//           SizedBox(
//             height: AppSpacing.smallVerticalSpacing(context),
//           ),
//           TextButton(
//             onPressed: onCancel ?? () => AppNavigator.pop(context),
//             child: Text(cancelButtonText),
//           ),
//         ],
//       ),
//     );
//   }
// }
