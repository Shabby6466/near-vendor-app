import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/category_selector.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_grid.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenCubit(),
      child: AppScaffold(
        extendBody: true,
        bgColor: ColorName.white,
        body: Stack(
          children: [
            Image.asset(Assets.images.nearVendorRightCut.path),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.mediumHorizontalSpacing(context),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Assets.icons.nearVendorBlueText.svg(),
                    ),
                  ),
                  SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.mediumHorizontalSpacing(context),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      child: AppTextField(
                        prefixIcon: Assets.icons.searchIcon.svg(),
                        hint: 'Search',
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.mediumHorizontalSpacing(context),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: AppSpacing.screenHeight(context) * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorName.primary,
                      ),
                      child: Center(child: Text('Advertisement')),
                    ),
                  ),
                  SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.icons.locationMarker.svg(),
                      SizedBox(
                        width: AppSpacing.smallHorizontalSpacing(context) * 0.5,
                      ),
                      Text(
                        'Location',
                        style: TextStyle(
                          color: ColorName.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.mediumHorizontalSpacing(context),
                    ),
                    child: Text(
                      'Best Vendors Near You!',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
                  const CategorySelector(),
                  const Expanded(child: ShopGrid()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
