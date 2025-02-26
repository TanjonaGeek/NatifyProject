import 'package:natify/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterOption extends StatelessWidget {
  final List<Map<String, dynamic>>? selectedOptions;
  final String? selectedItem;
  final ValueChanged<String?>? onSelected;
  final bool checkIfAge;
  final Widget content;

  const FilterOption(
      {super.key,
      this.selectedOptions,
      this.selectedItem,
      this.onSelected,
      required this.checkIfAge,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (checkIfAge == true && selectedOptions == null) content,
        if (checkIfAge == false && selectedOptions == null) content,
        if (checkIfAge == false && selectedOptions != null)
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Wrap(
              spacing: 3.0,
              children: selectedOptions!.map((item) {
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'],
                        size: 16,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${item['label']}'.tr.toUpperCase(),
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  showCheckmark: false,
                  selected: selectedItem == item['label'],
                  onSelected: (bool selected) {
                    onSelected!(selected ? item['label'] : "");
                  },
                  selectedColor: kPrimaryColor,
                  selectedShadowColor: Colors.transparent,
                  side: BorderSide(style: BorderStyle.none),
                  backgroundColor: Colors.grey.shade300,
                  labelPadding:
                      EdgeInsets.only(top: 2, left: 6, right: 6, bottom: 2),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
