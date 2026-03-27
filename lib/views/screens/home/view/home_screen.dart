import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/views/screens/home/widgets/category_selector.dart';
import 'package:nearvendorapp/views/screens/home/widgets/shop_grid.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/screens/search/view/search_screen.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => HomeScreenCubit(),
      child: AppScaffold(
        extendBody: true,
        bgColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Opacity(
              opacity: isDark ? 0.15 : 0.45,
              child: Image.asset(
                Assets.images.nearVendorRightCut.path,
                color: isDark ? theme.primaryColor.withOpacity(0.5) : null,
                colorBlendMode: isDark ? BlendMode.srcIn : null,
              ),
            ),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.mediumHorizontalSpacing(context),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Assets.icons.nearVendorBlueText.svg(
                              colorFilter: ColorFilter.mode(
                                theme.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.mediumHorizontalSpacing(context),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              AbsorbPointer(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: theme.cardColor.withOpacity(0.9),
                                    border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.1)) : null,
                                  ),
                                  child: AppTextField(
                                    prefixIcon: Assets.icons.searchIcon.svg(
                                      colorFilter: ColorFilter.mode(
                                        theme.iconTheme.color?.withOpacity(0.5) ?? Colors.grey,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    hint: 'Search',
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const VisualSearchScreen(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.camera_enhance_outlined,
                                        color: theme.iconTheme.color?.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.mic_none,
                                      color: theme.iconTheme.color?.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Advertisement',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 20),
                          SizedBox(
                            width: AppSpacing.smallHorizontalSpacing(context) * 0.5,
                          ),
                          Text(
                            'Location',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 16,
                              fontFamily: 'Poppins',
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
                          'Best Products Near You!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
                      const CategorySelector(),
                    ],
                  ),
                ),
                const ShopGrid(),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

