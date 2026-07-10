import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

part 'about.g.dart';

@TypedGoRoute<AboutRoute>(path: "/about")
class AboutRoute extends GoRouteData with $AboutRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AboutScreen();
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text.rich(
      style: Theme.of(context).textTheme.displayMedium,
      TextSpan(
        children: [
          TextSpan(text: "Made By OakFoil"),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse("https://github.com/OakFoil/nu_sched_gen"),
                )) {
                  throw Exception("Could not launch URL");
                }
              },
              icon: SvgPicture.asset(
                'assets/github.svg',
                width: 24 * 2,
                height: 24 * 2,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
