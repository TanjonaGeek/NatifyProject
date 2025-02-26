import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/features/Storie/presentation/pages/sectionAllStorie.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Allstoriepage extends ConsumerWidget {
  const Allstoriepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(infoUserStateNotifier);
    return ThemeSwitchingArea(
      child: Scaffold(
        body: Consumer(
          builder: (context, ref, child) {
            return Padding(
                padding: const EdgeInsets.only(left: 6, right: 6, top: 5),
                child: Column(
                  children: <Widget>[
                    Expanded(
                        child: SectionListAllOfStorie(
                      notifier: notifier,
                    ))
                  ],
                ));
          },
        ),
      ),
    );
  }
}
