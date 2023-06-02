import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

//import '../../providers/conversation_provider.dart';
import '../../widgets/communication_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../themes/theme.dart';
import '../../providers/chats_provider.dart';
import '../../widgets/chat_widget.dart';
import '../../widgets/text_input_widget.dart';
//import '../../widgets/menu_widget.dart';
import '../../widgets/text_widget.dart';
import '../../utils/scroll_functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showButtons = true;
  bool _isTyping = false;
  bool _showScrollDownButton = false;
  bool _isLoading = false;

  String? audiopath;
  late TextEditingController textEditingController;
  late ScrollController _scrollController;
  late FocusNode focusNode;

  void _onAudioRecordingStop(String path) {
    setState(() {
      audiopath = path;
    });
    if (kDebugMode) print('Recorded file path: $audiopath');
    //Path de memoria guardado para pasarselo a API
  }

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

  void _scrollToEnd() {
    scrollToEnd(_scrollController);
  }

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
      //initializeConversationProvider();
    });
  }
/*
  void initializeConversationProvider() {
    var conversationProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    var chatProvider = Provider.of<ChatProvider>(context, listen: false);

    var userId = FirebaseAuth.instance.currentUser?.uid;
    conversationProvider.loadConversations(userId!);

    var selectedConversationId = conversationProvider.selectedConversationId;
    if (selectedConversationId != null) {
      chatProvider.loadConversation(selectedConversationId, userId);
    }

    conversationProvider.addListener(() {
      var newSelectedConversationId =
          conversationProvider.selectedConversationId;
      if (newSelectedConversationId != null) {
        chatProvider.loadConversation(newSelectedConversationId, userId);
      }
    });
  }
*/
  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_scrollListener);
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    if (_isLoading) {
      // Si estamos cargando, mostramos el indicador de carga
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Si no, mostramos el resto de la interfaz de usuario

      return Scaffold(
        extendBodyBehindAppBar: true,
        //drawer: const MenuWidget(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: scaffoldBackgroundColor,
          leading: Padding(
            padding: const EdgeInsets.only(left:5, top:8),
            child: Image.asset("assets/images/logo.png", height: 15,),
          ),
          ),
         /* actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                var userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  // Crea una nueva conversación y obtiene su ID
                  var newConversationId =
                      await chatProvider.createNewConversation(userId);

                  // Limpia la lista de chat actual
                  chatProvider.clearChatList();

                  // Carga la nueva conversación en el chatProvider
                  chatProvider.loadConversation(newConversationId, userId);

                  var conversationProvider =
                      Provider.of<ConversationProvider>(context, listen: false);
                  conversationProvider.selectConversation(newConversationId);
                } else {
                  // Manejar el caso en el que el userId sea nulo
                  return;
                }
              },
            ),
          ],*/
        
        body: Column(
          children: [
            // Primera sección: lista de mensajes y botón de ir hacia abajo
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
            // Segunda sección: botones e input widget
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

  Future<void> sendMessageFCT({required ChatProvider chatProvider}) async {
   /* if (chatProvider.getChatList.length >= 12) {
      // Si ya se han enviado 12 mensajes (6 mensajes del usuario y 6 respuestas de la IA) en esta conversación, mostramos un mensaje y no enviamos más mensajes.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label:
                "Has alcanzado el límite de mensajes en esta conversación. Inicia una nueva conversación.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }*/

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
          // Manejar el caso en el que el userId sea nulo
          return;
        }
      }

      await chatProvider.sendMessageAndGetAnswers(
        msg: msg,
        conversationId: chatProvider.currentConversationId!,
      );

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
