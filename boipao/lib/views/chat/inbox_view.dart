import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'chat_view.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final querySelect = '''
            id,
            status,
            requester_id,
            material_id,
            created_at,
            materials!inner(id, title, donor_id, image_urls, profiles(display_name)),
            requester:profiles!claims_requester_id_fkey(display_name)
          ''';

      // Claims where I am the requester
      final myRequests = await _supabase
          .from('claims')
          .select(querySelect)
          .eq('requester_id', currentUserId);

      // Claims where I am the donor
      final myDonations = await _supabase
          .from('claims')
          .select(querySelect)
          .eq('materials.donor_id', currentUserId);

      final claimsResponse = [...myRequests, ...myDonations];
      
      // Sort combined results by created_at descending
      claimsResponse.sort((a, b) => 
        DateTime.parse(b['created_at'] as String).compareTo(DateTime.parse(a['created_at'] as String))
      );

      List<Map<String, dynamic>> list = [];
      for (var claim in claimsResponse) {
        final claimId = claim['id'] as String;
        // Fetch last message for this claim
        final msgRes = await _supabase
            .from('messages')
            .select('content, created_at, sender_id')
            .eq('claim_id', claimId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        final isDonor = claim['materials']['donor_id'] == currentUserId;
        final otherUser = isDonor ? claim['requester'] : claim['materials']['profiles'];
        final otherUserName = otherUser?['display_name'] as String? ?? 'User';
        final otherUserAvatar = otherUser?['avatar_url'] as String?;
        final materialTitle = claim['materials']['title'] as String? ?? 'Material';

        list.add({
          'claimId': claimId,
          'materialId': claim['materials']['id'],
          'materialTitle': materialTitle,
          'otherUserId': isDonor ? claim['requester_id'] : claim['materials']['donor_id'],
          'otherUserName': otherUserName,
          'otherUserAvatar': otherUserAvatar,
          'lastMessage': msgRes != null ? msgRes['content'] : 'No messages yet',
          'lastMessageTime': msgRes != null ? DateTime.tryParse(msgRes['created_at']) : null,
          'isDonor': isDonor,
          'status': claim['status'],
        });
      }

      setState(() {
        _conversations = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inbox & Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No active conversations yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Request or approve material claims to start chatting!',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final item = _conversations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            backgroundImage: item['otherUserAvatar'] != null
                                ? NetworkImage(item['otherUserAvatar'])
                                : null,
                            child: item['otherUserAvatar'] == null
                                ? Text(
                                    item['otherUserName'].isNotEmpty
                                        ? item['otherUserName'][0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['otherUserName'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (item['isDonor'] ? Colors.orange : AppColors.primary).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['isDonor'] ? 'Requester' : 'Donor',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: item['isDonor'] ? Colors.orange.shade800 : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Re: ${item['materialTitle']}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['lastMessage'],
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: item['status'] == 'completed'
                              ? const Icon(Icons.lock_rounded, color: Colors.grey)
                              : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatView(
                                  claimId: item['claimId'],
                                  receiverId: item['otherUserId'],
                                  title: item['materialTitle'],
                                  isCompleted: item['status'] == 'completed',
                                ),
                              ),
                            ).then((_) => _fetchConversations());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
