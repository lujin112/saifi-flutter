import 'package:flutter/material.dart';
import '../service/api_service.dart';
import 'add_child.dart';
import '../service/theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    

  _messages.add({
    "sender": "bot",
    "text": "Hi 👋 I'm the Saifi Assistant!\n\n"
          "I can help you with:\n"
          "Add a child\n"
          "Book an activity\n"
          "Manage your bookings\n"
          "Kids information\n"
          "About Saifi & Terms\n\n"
          "Just tell me what you need ",
  });
}

  

  

  
Future<void> _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  setState(() {
    _messages.add({
      "sender": "user",
      "text": text,
    });
  });

  _controller.clear();
  _scrollToBottom();

  try {
    final res = await ApiService.sendChatbotMessage(
      text: text,
      lang: "en",
    );

    final reply = res["reply"] ?? "Sorry, I didn’t quite understand that. Could you clarify?";

    final intent = res["intent"];

    setState(() {
      _messages.add({
        "sender": "bot",
        "text": reply,
      });
    });

    _scrollToBottom();

    // Action mapping (بسيط الآن)
 if (intent == "add_child") {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddChildScreen()),
  );
}
if (intent == "book_activity") {
  Navigator.pushNamed(context, "/browseActivities");
}
if (intent == "track_my_booking") {
  Navigator.pushNamed(context, "/bookings");
}
if (intent == "kids_information") {
  Navigator.pushNamed(context, "/kidsInfo");
}


  } catch (e) {
    setState(() {
      _messages.add({
        "sender": "bot",
        "text": "Something went wrong. Please try again 🙏",

      });
    });
  }
}

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg["sender"] == "user";

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.75,
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
                            color:
                                isUser ? Colors.white : AppColors.textDark,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 8.0),
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
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color:
                                  AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                                color: AppColors.primary),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              Color(0xFF64AFAA)
                            ],
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
