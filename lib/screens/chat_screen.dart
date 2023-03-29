import 'dart:math';

import 'package:ask_anything/constant/constants.dart';
import 'package:ask_anything/models/chat_model.dart';
import 'package:ask_anything/providers/chats_provider.dart';
import 'package:ask_anything/providers/models_provider.dart';
import 'package:ask_anything/services/api_services.dart';
import 'package:ask_anything/services/assets_manager.dart';
import 'package:ask_anything/services/services.dart';
import 'package:ask_anything/widgets/chat_widget.dart';
import 'package:ask_anything/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late FocusNode focusNode;
  late ScrollController _listScrollController;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("ChatGPT"),
          actions: [
            IconButton(
                onPressed: () async {
                  await Services.showModalSheet(context: context);
                },
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                ))
          ],
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetManager.openaiLogo),
          ),
        ),
        body: SafeArea(
            child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getChatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider
                          .getChatList[index].msg, //chatList[index].msg,
                      chatIndex: chatProvider.getChatList[index].chatIndex,
                    );
                  }),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      focusNode: focusNode,
                      style: TextStyle(color: Colors.white),
                      controller: textEditingController,
                      onSubmitted: (value) async {
                        // send message
                        await sendMessageToOpenAi(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "How can I help you",
                          hintStyle: TextStyle(color: Colors.grey)),
                    )),
                    IconButton(
                        onPressed: () async {
                          await sendMessageToOpenAi(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            )
          ],
        )));
  }

  void scrolListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut);
  }

  Future<void> sendMessageToOpenAi(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You can't send multiple messages",
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
            label: "Please type a message",
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
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      // chatList.addAll(await ApiService.sendMessages(
      //     message: textEditingController.text,
      //     modelId: modelsProvider.getCurrentModel));
      setState(() {});
    } catch (e) {
      print("e $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTyping = false;
        scrolListToEnd();
      });
    }
  }
}
