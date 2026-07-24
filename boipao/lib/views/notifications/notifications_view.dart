import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/notification_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/material_model.dart';
import '../../models/notification_model.dart';
import '../listings/listing_details_view.dart';
import '../chat/inbox_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifCtrl = context.read<NotificationController>();
      notifCtrl.fetchNotifications();
      notifCtrl.subscribeToNotifications();
    });
  }

  void _handleNotificationTap(NotificationModel notification) async {
    final notifCtrl = context.read<NotificationController>();
    if (!notification.isRead) {
      notifCtrl.markAsRead(notification.id);
    }

    if (notification.type == 'claim_request' && notification.referenceId != null) {
      // Fetch material details and navigate directly to Material Detail Page
      try {
        final res = await Supabase.instance.client
            .from('materials')
            .select('*')
            .eq('id', notification.referenceId!)
            .single();

        final material = MaterialModel.fromJson(res);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailsView(material: material),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open material: $e')),
          );
        }
      }
    } else if (notification.type == 'claim_approved' || notification.type == 'claim_completed') {
      // Navigate to Inbox
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InboxView()),
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'claim_request':
        return Icons.inventory_2_rounded;
      case 'claim_approved':
        return Icons.check_circle_rounded;
      case 'claim_completed':
        return Icons.favorite_rounded;
      case 'verification_update':
        return Icons.verified_user_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'claim_request':
        return Colors.orange;
      case 'claim_approved':
        return AppColors.primary;
      case 'claim_completed':
        return Colors.pink;
      case 'verification_update':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifCtrl = context.watch<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (notifCtrl.notifications.any((n) => !n.isRead))
            TextButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
              label: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onPressed: () => notifCtrl.markAllAsRead(),
            ),
        ],
      ),
      body: notifCtrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : notifCtrl.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Activity updates will appear right here',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => notifCtrl.fetchNotifications(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notifCtrl.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifCtrl.notifications[index];
                      final typeColor = _getColorForType(notif.type);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: notif.isRead ? AppColors.surface : AppColors.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notif.isRead ? AppColors.border : typeColor.withOpacity(0.4),
                            width: notif.isRead ? 1 : 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: typeColor.withOpacity(0.15),
                            child: Icon(_getIconForType(notif.type), color: typeColor, size: 22),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              notif.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: notif.isRead ? Colors.grey.shade700 : Colors.black87,
                              ),
                            ),
                          ),
                          onTap: () => _handleNotificationTap(notif),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
