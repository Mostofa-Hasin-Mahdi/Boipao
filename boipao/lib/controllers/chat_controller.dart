import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

enum ChatState { initial, loading, success, error }

class ChatController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  ChatState _state = ChatState.initial;
  ChatState get state => _state;
  bool get isLoading => _state == ChatState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  RealtimeChannel? _subscription;

  void _setState(ChatState state) {
    _state = state;
    notifyListeners();
  }

  /// Fetch message history for a specific claim
  Future<void> fetchMessages(String claimId) async {
    try {
      _setState(ChatState.loading);

      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('claim_id', claimId)
          .order('created_at', ascending: true);

      _messages = (response as List)
          .map((item) => MessageModel.fromMap(item))
          .toList();

      _setState(ChatState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ChatState.error);
    }
  }

  /// Subscribe to real-time message updates for a claim (resource optimized for Free Tier)
  void subscribeToMessages(String claimId) {
    unsubscribe(); // Ensure previous subscriptions are cleaned up

    _subscription = _supabase
        .channel('public:messages:claim_id=eq.$claimId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'claim_id',
            value: claimId,
          ),
          callback: (payload) {
            final newMsg = MessageModel.fromMap(payload.newRecord);
            // Avoid duplicate insertion if already added optimistically
            if (!_messages.any((m) => m.id == newMsg.id)) {
              _messages.add(newMsg);
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  /// Unsubscribe from real-time stream when screen disposes
  void unsubscribe() {
    if (_subscription != null) {
      _supabase.removeChannel(_subscription!);
      _subscription = null;
    }
  }

  /// Send a chat message
  Future<bool> sendMessage({
    required String claimId,
    required String receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;

    final currentUserId = _supabase.auth.currentUser!.id;
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // Optimistic UI update
    final optimisticMsg = MessageModel(
      id: tempId,
      claimId: claimId,
      senderId: currentUserId,
      receiverId: receiverId,
      content: content.trim(),
      isRead: false,
      createdAt: DateTime.now(),
    );

    _messages.add(optimisticMsg);
    notifyListeners();

    try {
      final res = await _supabase.from('messages').insert({
        'claim_id': claimId,
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'content': content.trim(),
      }).select().single();

      // Replace optimistic message with actual DB record
      final insertedMsg = MessageModel.fromMap(res);
      final idx = _messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        _messages[idx] = insertedMsg;
      }
      notifyListeners();
      return true;
    } catch (e) {
      // Remove optimistic message on failure
      _messages.removeWhere((m) => m.id == tempId);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}
