import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: AppScaffold(
        appBar: AppBar(
          actions: [
            InkWell(
              onTap: () {
                AppNavigator.pushReplacement(context, LoginScreen());
              },
              child: Icon(Icons.logout, color: Colors.black),
            ),
          ],
        ),
        bgColor: ColorName.white,
        body: Column(children: [  
            
          ],
        ),
      ),
    );
  }
}
