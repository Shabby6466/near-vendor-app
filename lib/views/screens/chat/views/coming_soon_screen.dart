import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        bgColor: ColorName.white,
        body: Center(child: Text('Coming Soon')),
    );
  }
}
