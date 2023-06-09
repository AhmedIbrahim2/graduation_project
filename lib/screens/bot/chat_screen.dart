import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chatmessage.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;
  bool _isImageSearch = false;

  bool _isTyping = false;

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
        token: "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",
        baseOption:
            HttpSetup(receiveTimeout: const Duration(milliseconds: 60000)));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();
    const kTranslateModelV3 = "text-davinci-003";

    final request =
        CompleteText(prompt: message.text, model: Model.textDavinci3);

    // final response = await chatGPT!.onCompleteText(request: request);
    final response = await chatGPT!.onCompletion(request: request);
    Vx.log(response!.choices[0].text);
    insertNewData(response.choices[0].text, isImage: false);
  }

  void insertNewData(String response, {bool isImage = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: isImage,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
                hintText: "Question/description"),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _isImageSearch = false;
                _sendMessage();
              },
            ),
          ],
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "OpenAI's ChatGPT \n",
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.cyan,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Flexible(
                    child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                )),
                if (_isTyping) const ThreeDots(),
                const Divider(
                  height: 1.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                  ),
                  child: _buildTextComposer(),
                )
              ],
            ),
          )),
    );
  }
}
