import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/communication_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../themes/theme.dart';
import '../../providers/chats_provider.dart';
import '../../widgets/chat_widget.dart';
import '../../widgets/text_input_widget.dart';
import '../../widgets/text_widget.dart';
import '../../utils/scroll_functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Definición de variables
  bool _showButtons = true;
  bool _isTyping = false;
  bool _showScrollDownButton = false;
  bool _isLoading = false;

  String? audiopath;
  late TextEditingController textEditingController;
  late ScrollController _scrollController;
  late FocusNode focusNode;
  String prevMsg1 = '';
  String prevMsg2 = '';

  // Callback cuando la grabación de audio se detiene
  void _onAudioRecordingStop(String path) {
    setState(() {
      audiopath = path;
    });
    if (kDebugMode) print('Ruta del archivo grabado: $audiopath');
  }

  // Listener para el desplazamiento en la lista de chats
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _showScrollDownButton = false;
      });
    } else {
      setState(() {
        _showScrollDownButton = true;
      });
    }
  }

  // Desplazar hacia el final de la lista de chats
  void _scrollToEnd() {
    scrollToEnd(_scrollController);
  }

  // Mostrar mensaje de error de grabación
  void _showFailRecordingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: warning,
        content: const Padding(
          padding: EdgeInsets.all(2.0),
          child: Text(
            "Por favor, mantenga pulsado para hablar",
            style: TextStyle(color: Colors.white),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Alternar la visibilidad del chat
  void _toggleChatVisibility() {
    setState(() {
      _showButtons = !_showButtons;
    });
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    textEditingController = TextEditingController();
    focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.onNewMessageReceived = _scrollToEnd;

      var userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && chatProvider.currentConversationId == null) {
        setState(() {
          _isLoading = true;
        });
        chatProvider.loadLastConversationOrStartNew(userId).then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_scrollListener);
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  ///[USER_INTERFACE]
  ///--------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: scaffoldBackgroundColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5, top: 8),
            child: Image.asset(
              "assets/images/logo.png",
              height: 15,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: chatProvider.getChatList.length,
                    itemBuilder: (context, index) {
                      return ChatWidget(
                        msg: chatProvider.getChatList[index].msg,
                        chatIndex: chatProvider.getChatList[index].chatIndex,
                      );
                    },
                  ),
                  if (_showScrollDownButton)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        backgroundColor: accentTwo,
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        child: const Icon(Icons.arrow_downward),
                      ),
                    ),
                ],
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            if (!_showButtons)
              Material(
                color: scaffoldBackgroundColor,
                child: InputWidget(
                  focusNode: focusNode,
                  textEditingController: textEditingController,
                  onSendPressed: () async {
                    await sendMessageFCT(chatProvider: chatProvider);
                  },
                  onHidePressed: _toggleChatVisibility,
                ),
              )
            else
              CommunicationButtons(
                toggleChatVisibility: _toggleChatVisibility,
                // Llamamos a getChatContext para obtener el contexto actualizado
                contexto: getChatContext(chatProvider),
                onStop: _onAudioRecordingStop,
                onShortPress: _showFailRecordingMessage,
                chatProvider: Provider.of<ChatProvider>(context, listen: false),
                setIsTyping: (bool value) {
                  setState(() {
                    _isTyping = value;
                    _scrollToEnd();
                  });
                },
                conversationId: chatProvider.currentConversationId ?? '',
                lenght: chatProvider.getChatList.length,
              ),
          ],
        ),
      );
    }
  }

  String getChatContext(ChatProvider chatProvider) {
    String prevMsg1, prevMsg2;
    if (chatProvider.getChatList.length >= 2) {
      prevMsg1 =
          chatProvider.getChatList[chatProvider.getChatList.length - 2].msg;
      prevMsg2 =
          chatProvider.getChatList[chatProvider.getChatList.length - 1].msg;
    } else if (chatProvider.getChatList.length == 1) {
      prevMsg1 = '';
      prevMsg2 = chatProvider.getChatList[0].msg;
    } else {
      prevMsg1 = '';
      prevMsg2 = '';
    }
    return "(contexto de los 2 mensajes previos del usuario: -$prevMsg1 -$prevMsg2) MENSAJE ACTUAL:";
  }

  ///[ENVIAR_MENSAJES_CHATGPT_ESCRITO]
  ///-------------------------------------------------------------------------
  Future<void> sendMessageFCT({required ChatProvider chatProvider}) async {
    String contexto = getChatContext(chatProvider);
    if (_isTyping) {
      _scrollToEnd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "No puedes enviar más de un mensaje a la vez",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Por favor, escribe un mensaje",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        _scrollToEnd();
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });

      if (chatProvider.currentConversationId == null) {
        var userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await chatProvider.createNewConversation(userId);
        } else {
          return;
        }
      }

      await chatProvider.sendMessageAndGetAnswers(
          msg: msg,
          conversationId: chatProvider.currentConversationId!,
          contexto: contexto);

      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: error.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTyping = false;
        _scrollToEnd();
      });
    }
  }
}
