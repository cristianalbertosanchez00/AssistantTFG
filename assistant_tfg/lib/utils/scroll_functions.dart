import 'package:flutter/material.dart';

void scrollToEnd(ScrollController scrollController) {
  scrollController.animateTo(
    scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOut,
  );
}
