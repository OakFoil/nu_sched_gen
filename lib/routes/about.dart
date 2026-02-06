import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'about.g.dart';

@TypedGoRoute<AboutRoute>(path: "/about")
class AboutRoute extends GoRouteData with _$AboutRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AboutScreen();
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Center(child: DisplayText("Made By OakFoil"));
}
