import 'package:assistant_tfg/themes/theme.dart';
import 'package:assistant_tfg/views/actions/actions_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ActionsSendMessage extends StatefulWidget {
  final Future<String> text;
  final ButtonType buttonType;

  const ActionsSendMessage(
      {Key? key, required this.text, required this.buttonType})
      : super(key: key);

  @override
  State<ActionsSendMessage> createState() => _ActionsSendMessageState();
}

class _ActionsSendMessageState extends State<ActionsSendMessage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Comprobar Envío'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: widget.text,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // handle error, for example:
              return Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              );
            }

            _controller.text = snapshot.data ?? '';

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              10), 
                          borderSide: BorderSide(color: cardColor),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print('Edited text: ${_controller.text}');
                      }
                      // TODO: implement your send message logic here
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Enviar',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            );
          } else {
            // While waiting for the future to complete, show a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
