import 'package:flutter/material.dart';
import 'package:get/get.dart';

showLoadingDialog({
  required BuildContext context,
  required String message,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message.tr,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
