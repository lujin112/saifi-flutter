import 'package:flutter/material.dart';
import '../service/dialogflow_service.dart';
import '../service/theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final DialogflowService _dialogflow = DialogflowService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _autoStartConversation(); // << يبدأ المحادثة أول ما تفتح الصفحة
  }

  void _autoStartConversation() async {
    // نرسل trigger message للـ Dialogflow (غالبًا Intent الترحيب يشتغل مع "hi")
    final botReply = await _dialogflow.sendMessage("hi");

    setState(() {
      _messages.add({"role": "bot", "text": botReply});
    });

    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": userMessage});
    });

    _scrollToBottom();

    final botReply = await _dialogflow.sendMessage(userMessage);

    setState(() {
      _messages.add({"role": "bot", "text": botReply});
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // رأس بسيط بدون AppBar، فيه لوقو أو عنوان صغير
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Saifi Assistant 🤖",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark.withOpacity(0.9),
                  ),
                ),
              ),

              // المحادثة
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg["role"] == "user";

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: isUser
                                ? const Radius.circular(14)
                                : const Radius.circular(2),
                            bottomRight: isUser
                                ? const Radius.circular(2)
                                : const Radius.circular(14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          msg["text"]!,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: isUser ? Colors.white : AppColors.textDark,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // حقل الإدخال
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Ask me anything...",
                          hintStyle: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.grey[500],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF64AFAA)],
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
