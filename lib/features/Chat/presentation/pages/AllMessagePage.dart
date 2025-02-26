import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/features/Chat/presentation/widget/sectionChatList.dart';
import 'package:natify/features/Chat/presentation/widget/sectionListUserOnline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:natify/features/User/presentation/widget/list/sectionHeader.dart';

class Allmessagepage extends ConsumerWidget {
  const Allmessagepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeSwitchingArea(
      child: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 1.0,
                      ),
                      SectionHeader(
                        showFilterOption: false,
                        nameSearch: '',
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      ListUserOnline(),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.3,
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    "Messages récents".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(child: ChatList())
              ]);
        }),
      ),
    );
  }
}
