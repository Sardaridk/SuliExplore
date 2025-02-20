import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tourism_app/main.dart';

const apiKey = 'AIzaSyC0NacOWW0jpXAOwBwXim0EntRFMvYZc04';
// Replace with your API key

// Message class to handle both text and images
class Message {
  final String? text;
  final String? imagePath;
  final bool isFromUser;

  Message({this.text, this.imagePath, required this.isFromUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key, required this.title, required TextStyle titleStyle});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(
                  context); // Pop only if there’s a screen to go back to
            } else {
              // Optional: Show a message or navigate to a default screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TourismApp()),
              );
            }
          },
        ),
      ),
      body: const ChatWidget(),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _chatModel;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;
  final ImagePicker _picker = ImagePicker();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _chatModel = GenerativeModel(
      model: 'gemini-1.5-flash', // Updated model version
      apiKey: apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash', // Updated model version
      apiKey: apiKey,
    );
    _chat = _chatModel.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _messages.add(Message(
            imagePath: image.path,
            isFromUser: true,
          ));
          _scrollDown();
        });
        await _analyzeImage(image);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    setState(() => _loading = true);

    try {
      final List<int> imageBytes = await image.readAsBytes();
      final imagePart = DataPart('image/jpeg', Uint8List.fromList(imageBytes));
      final prompt = TextPart("Describe what you see in this image in detail.");
      final content = Content.multi([prompt, imagePart]);

      // Use vision model instead of chat model for image analysis
      final response = await _visionModel.generateContent([content]);
      final responseText = response.text ?? 'Could not analyze image';

      setState(() {
        _messages.add(Message(
          text: responseText,
          isFromUser: false,
        ));
        _scrollDown();
      });
    } catch (e) {
      _showError('Error analyzing image: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _loading = true;
      _messages.add(Message(text: message, isFromUser: true));
    });

    try {
      _textController.clear();
      final response = await _chat.sendMessage(Content.text(message));
      final responseText = response.text ?? 'No response';

      setState(() {
        _messages.add(Message(text: responseText, isFromUser: false));
        _loading = false;
        _scrollDown();
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError(e.toString());
    } finally {
      _textFieldFocus.requestFocus();
    }
  }

  InputDecoration textFieldDecoration(BuildContext context, String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, idx) =>
                MessageWidget(message: _messages[idx]),
            itemCount: _messages.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              PopupMenuButton<ImageSource>(
                icon: const Icon(Icons.attach_file),
                onSelected: _pickImage,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ImageSource.camera,
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text('Take Photo'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: ImageSource.gallery,
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Choose from Gallery'),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TextField(
                  decoration: textFieldDecoration(context, 'Enter a prompt...'),
                  controller: _textController,
                  focusNode: _textFieldFocus,
                  onSubmitted: _sendChatMessage,
                ),
              ),
              const SizedBox(width: 8),
              if (!_loading)
                IconButton(
                  onPressed: () => _sendChatMessage(_textController.text),
                  icon: const Icon(Icons.send),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageWidget extends StatefulWidget {
  const MessageWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  String displayText = '';
  bool isAnimating = true;
  // Add this flag to track if animation has already played
  static final Set<String> _animatedMessages = {};

  @override
  void initState() {
    super.initState();
    if (widget.message.isFromUser || widget.message.imagePath != null) {
      displayText = widget.message.text ?? '';
      isAnimating = false;
    } else {
      // Generate a unique identifier for this message
      final messageId = widget.message.text ?? '';
      if (_animatedMessages.contains(messageId)) {
        // If this message has already been animated, show it immediately
        displayText = messageId;
        isAnimating = false;
      } else {
        // Otherwise, start the animation
        _startAnimation(messageId);
      }
    }
  }

  void _startAnimation(String messageId) async {
    final text = widget.message.text ?? '';
    for (int i = 0; i < text.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          displayText = text.substring(0, i + 1);
        });
      }
    }
    if (mounted) {
      setState(() {
        isAnimating = false;
      });
      // Mark this message as animated
      _animatedMessages.add(messageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.message.isFromUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.message.isFromUser
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.message.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.message.imagePath!),
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              if (widget.message.imagePath != null &&
                  widget.message.text != null)
                const SizedBox(height: 8),
              if (widget.message.text != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: MarkdownBody(data: displayText),
                    ),
                    if (!widget.message.isFromUser && isAnimating)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
