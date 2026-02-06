import 'package:nu_sched_gen/routes/about.dart';
import 'package:nu_sched_gen/routes/sched_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:nu_sched_gen/routes/home.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Page extends StatefulWidget {
  final Widget child;

  const Page({required this.child, super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  int get selectedIndex => pathToIndex[GoRouterState.of(context).uri.path]!;
  set selectedIndex(int newIndex) {
    navigatorKey.currentContext!.go(indexToPath[newIndex]);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: AdaptiveScaffold(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: "Home"),
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: "Generate Schedule",
        ),
        NavigationDestination(icon: Icon(Icons.info), label: "About"),
      ],
      selectedIndex: selectedIndex,
      onSelectedIndexChange: (newIndex) {
        selectedIndex = newIndex;
      },
      body: (_) => widget.child,
    ),
  );
}

List<String> indexToPath = ["/", "/generate-schedule", "/about"];
Map<String, int> pathToIndex = {
  for (final (index, page) in indexToPath.indexed) page: index,
};

var routerConfig = GoRouter(
  routes: [
    ShellRoute(
      navigatorKey: navigatorKey,
      builder: (context, state, child) => Page(child: child),
      routes: [$homeRoute, $aboutRoute, $schedGenRoute],
    ),
  ],
);
