import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../themes/theme.dart';
import '../../utils/platform.dart';
import 'actions_sendMessage.dart';

enum ButtonType { resumir, explicar, gramatica, ortografia }

class ActionsScreen extends StatefulWidget {
  const ActionsScreen({Key? key}) : super(key: key);

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  XFile? imageFile;
  String scannedText = "";

  Future pickImageGalleryOrPhoto(
      ImageSource imageSource, ButtonType buttonType) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: imageSource);
      if (pickedImage != null) {
        imageFile = pickedImage;
        setState(() {});
        final textoReconocido =
            await ApiService.getRecognisedText(pickedImage.path);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActionsSendMessage(
              text: Future.value(textoReconocido),
              buttonType: buttonType,
            ),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Fallo al abrir imagen: $e');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Fallo al reconocer texto: $e');
      }
    }
  }

  ButtonType? selectedButtonType;

  Future<void> _showImageSourceDialog(ButtonType buttonType) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              if (PlatformUtils.isMobilePlatform(context)) ...{
                ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Cámara'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.camera);
                    }),
              }
            ],
          ),
        );
      },
    );

    setState(() {
      if (source != null) {
        selectedButtonType = buttonType;
      }
    });
    if (source != null) {
      pickImageGalleryOrPhoto(source, buttonType);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 70,
              ),
              const Text(
                'Acciones',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(
                height: 20,
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                children: [
                  _buildButton('Resumir Texto', ButtonType.resumir),
                  _buildButton('Explicar Texto', ButtonType.explicar),
                  _buildButton('Mejorar Gramática', ButtonType.gramatica),
                  _buildButton('Mejorar Ortografía', ButtonType.ortografia),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, ButtonType buttonType) {
    final isSelected = selectedButtonType == buttonType;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? primary : Colors.grey.withOpacity(0.3),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        onTap: () => _showImageSourceDialog(buttonType),
      ),
    );
  }
}
