import 'package:flutter/material.dart';
import '../themes/theme.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final VoidCallback onSendPressed;
  final VoidCallback onHidePressed;

  const InputWidget({
    Key? key,
    required this.textEditingController,
    required this.focusNode,
    required this.onSendPressed,
    required this.onHidePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  border: (InputBorder.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSendPressed,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                    color: Colors.white,
                    onPressed: onHidePressed,
                    icon: const Icon(Icons.keyboard_arrow_down)),
              )
            ],
          )
        ],
      ),
    );
  }
}
