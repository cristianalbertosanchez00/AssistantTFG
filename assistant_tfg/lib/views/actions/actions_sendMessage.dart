import 'package:assistant_tfg/themes/theme.dart';
import 'package:assistant_tfg/views/actions/actions_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/chat_model.dart';
import '../../services/api_service.dart';

class ActionsSendMessage extends StatefulWidget {
  final Future<String> text;
  final ButtonType buttonType;

  const ActionsSendMessage({
    Key? key,
    required this.text,
    required this.buttonType,
  }) : super(key: key);

  @override
  State<ActionsSendMessage> createState() => _ActionsSendMessageState();
}

class _ActionsSendMessageState extends State<ActionsSendMessage> {
  late TextEditingController _controller;
  late TextEditingController _responseController;
  bool showResponseTextField = false;
  String buttonText = 'Enviar';
  bool isSending = false;
  String comanda = '';
  String? returnedMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _responseController = TextEditingController();

    widget.text.then((value) {
      _controller.text = value;
    });

    switch (widget.buttonType) {
      case ButtonType.explicar:
        buttonText = 'EXPLICAR TEXTO';
        comanda =
            "Por favor, explica el siguiente texto (Comienza diciendo 'Esta es la explicación a tu texto...'): ";
        break;
      case ButtonType.resumir:
        buttonText = 'RESUMIR TEXTO';
        comanda =
            "Por favor, resume el siguiente texto (Comienza diciendo 'Este es el resumen de tu texto...'): ";
        break;
      case ButtonType.gramatica:
        buttonText = 'REVISAR GRAMÁTICA';
        comanda =
            "Por favor, revisa la gramática del siguiente texto (Comienza diciendo 'Esta es la revisión de tu texto...'): ";
        break;
      case ButtonType.ortografia:
        buttonText = 'REVISAR ORTOGRAFÍA';
        comanda =
            "Por favor, revisa la ortografía del siguiente texto (Comienza diciendo 'Esta es la revisión de tu texto...'): ";
        break;
      default:
        buttonText = 'ACCION DESCONOCIDA';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _sendAndReceiveMessage() async {
    if (_controller.text.isEmpty) {
      return;
    }

    setState(() {
      isSending = true;
      showResponseTextField = false;
      buttonText = 'Enviando...';
    });

    List<ChatModel> response = await ApiService.sendMessageGPT(
      message: comanda + _controller.text,
    );

    if (response.isNotEmpty) {
      setState(() {
        returnedMessage = response[0].msg;
        _responseController.text = returnedMessage ?? '';
        showResponseTextField = true;
        buttonText = 'Reenviar';
      });
    }

    setState(() {
      isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Comprobar Envío'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 110,
              ),
              Text(
                buttonText,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _controller,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: neutralGrayColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: neutralGrayColor),
                  ),
                ),
              ),
              if (showResponseTextField)
                const SizedBox(
                  height: 15,
                ),
              if (showResponseTextField)
                TextField(
                  controller: _responseController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: cardColor),
                    ),
                  ),
                ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: isSending ? null : _sendAndReceiveMessage,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).primaryColor,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isSending
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
