import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Widget build(BuildContext context) => Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DisplayText("Made By OakFoil"),
        IconButton(
          onPressed: () async {
            if (!await launchUrl(
              Uri.parse("https://github.com/OakFoil/nu_sched_gen"),
            )) {
              throw Exception("Could not launch URL");
            }
          },
          icon: Icon(SimpleIcons.github, size: 24 * 2),
        ),
      ],
    ),
  );
}
