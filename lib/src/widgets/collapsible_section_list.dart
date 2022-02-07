import 'package:cake_wallet/src/widgets/standard_list.dart';
import 'package:flutter/material.dart';


class CollapsibleSectionList extends SectionStandardList {
  bool isCollapsible = false;

  CollapsibleSectionList(
      int sectionCount,
      bool hasTopSeparator,
      int Function(int sectionIndex) itemCounter,
      Widget Function(BuildContext context, int sectionIndex, int itemIndex)
      itemBuilder)
      :super(
          sectionCount: sectionCount,
          hasTopSeparator: hasTopSeparator,
          itemCounter: itemCounter,
          itemBuilder: itemBuilder);

  @override
  List<Widget> buildSection(int itemCount, List<Widget> items, int sectionIndex,
      BuildContext context) {
    items.add(ExpansionTile(
      title: null,
      children: super.buildSection(itemCount, items, sectionIndex, context),
    ));
    return items;
  }

