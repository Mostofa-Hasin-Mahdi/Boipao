import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

enum NotificationState { initial, loading, success, error }

class NotificationController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  NotificationState _state = NotificationState.initial;
  NotificationState get state => _state;
  bool get isLoading => _state == NotificationState.loading;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  RealtimeChannel? _subscription;

  void _setState(NotificationState state) {
    _state = state;
    notifyListeners();
  }

  /// Fetch notifications for the logged in user
  Future<void> fetchNotifications() async {
    try {
      _setState(NotificationState.loading);
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _setState(NotificationState.success);
        return;
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _notifications = (response as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList();

      _setState(NotificationState.success);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      _setState(NotificationState.error);
    }
  }

  /// Subscribe to real-time notification updates
  void subscribeToNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    unsubscribe();

    _subscription = _supabase
        .channel('public:notifications:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newNotif = NotificationModel.fromJson(payload.newRecord);
            _notifications.insert(0, newNotif);
            notifyListeners();
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    if (_subscription != null) {
      _supabase.removeChannel(_subscription!);
      _subscription = null;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        // Optimistic
        final updated = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          referenceId: _notifications[index].referenceId,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _notifications[index] = updated;
        notifyListeners();

        await _supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('id', id);
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          referenceId: n.referenceId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }

  /// Send in-app notification helper
  Future<void> sendNotification({
    required String recipientUserId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': recipientUserId,
        'title': title,
        'body': body,
        'type': type,
        'reference_id': referenceId,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}
