import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubits/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/widgets/my_wishes_view.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';

class WishlistMainScreen extends StatelessWidget {
  const WishlistMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final isAuthenticated = context.read<SessionCubit>().isAuthenticated;

        if (!isAuthenticated) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'My Wishes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: const _GuestStateView(),
          );
        }

        return BlocProvider(
          create: (context) => UserWishlistCubit()..getMyWishlists(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            // Add minimal app bar for context
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'My Wishes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: const MyWishesView(),
          ),
        );
      },
    );
  }
}

class _GuestStateView extends StatelessWidget {
  const _GuestStateView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 80,
              color: ColorName.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a wish list to alert local vendors when you can\'t find what you need. Please sign in to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                AppNavigator.push(context, const LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Sign In / Register',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
