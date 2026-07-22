import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/groq_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final StorageService _storage;

  List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _error;
  String? _apiKey;

  static const _uuid = Uuid();

  ChatProvider(this._storage);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get error => _error;
  String? get apiKey => _apiKey;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> loadApiKey() async {
    _apiKey = await _storage.getGroqApiKey();
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _storage.saveGroqApiKey(key);
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    _error = null;
    notifyListeners();
  }

  Future<void> sendCustomerMessage(String content) async {
    if (_isSending) return;
    _addUserMessage(content);
    _addLoadingMessage();
    await _sendToGroq(content, isCustomer: true);
  }

  Future<void> sendBartenderMessage(String content) async {
    if (_isSending) return;
    _addUserMessage(content);
    _addLoadingMessage();
    await _sendToGroq(content, isCustomer: false);
  }

  void _addUserMessage(String content) {
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: content,
      isUser: true,
    ));
    notifyListeners();
  }

  void _addLoadingMessage() {
    _isSending = true;
    _messages.add(ChatMessage(
      id: 'loading',
      content: '',
      isUser: false,
      isLoading: true,
    ));
    notifyListeners();
  }

  Future<void> _sendToGroq(String latestMessage, {required bool isCustomer}) async {
    try {
      if (!hasApiKey) {
        _removeLoadingMessage();
        _error = 'Please set your Groq API key in Settings.';
        _isSending = false;
        notifyListeners();
        return;
      }

      final groq = GroqService(_apiKey!);

      final history = _messages
          .where((m) => !m.isLoading && m.id != 'loading')
          .take(_messages.length - 2)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final String response;
      if (isCustomer) {
        response = await groq.customerChatResponse(
          conversationHistory: history,
          latestMessage: latestMessage,
        );
      } else {
        response = await groq.bartenderAssistResponse(
          conversationHistory: history,
          latestMessage: latestMessage,
        );
      }

      _removeLoadingMessage();
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        content: response,
        isUser: false,
      ));
      _error = null;
    } catch (e) {
      _removeLoadingMessage();
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void _removeLoadingMessage() {
    _messages.removeWhere((m) => m.id == 'loading');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
