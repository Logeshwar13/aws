// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_form_dialog.dart';
import '../../providers/events_provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/members_provider.dart';
import '../../providers/gallery_provider.dart';
import '../../models/member_model.dart';
import '../../models/gallery_item_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/footer_widget.dart';
import '../../widgets/custom_image_cropper.dart';



class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _contacts = [];
  bool _loadingContacts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    setState(() => _loadingContacts = true);
    try {
      final contacts = await FirebaseService.fetchContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _loadingContacts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingContacts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $e')),
        );
      }
    }
  }

  Future<void> _showEditStatsDialog(BuildContext context) async {
    final stats = await FirebaseService.fetchCommunityStats();
    final membersCtrl = TextEditingController(text: stats['members']?.toString() ?? '0');
    final certifiedCtrl = TextEditingController(text: stats['certified']?.toString() ?? '0');
    final projectsCtrl = TextEditingController(text: stats['projects']?.toString() ?? '0');
    bool showPlusOnMembers = stats['showPlusOnMembers'] ?? false;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Community Stats'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: membersCtrl,
                decoration: const InputDecoration(labelText: 'Members Count'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Show "+" on Members Count'),
                subtitle: const Text('Display as "650+" instead of "650"'),
                value: showPlusOnMembers,
                onChanged: (value) {
                  setState(() {
                    showPlusOnMembers = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: certifiedCtrl,
                decoration: const InputDecoration(labelText: 'Certified Count'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: projectsCtrl,
                decoration: const InputDecoration(labelText: 'Projects Count'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseService.updateCommunityStats({
                  'members': int.tryParse(membersCtrl.text) ?? 0,
                  'certified': int.tryParse(certifiedCtrl.text) ?? 0,
                  'projects': int.tryParse(projectsCtrl.text) ?? 0,
                  'showPlusOnMembers': showPlusOnMembers,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stats updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating stats: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, {String? editEventId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EventFormDialog(editEventId: editEventId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prov = context.watch<EventsProvider>();
    final events = prov.events;
    final auth = context.watch<AuthProvider>();
    final membersProv = context.watch<MembersProvider>();
    final galleryProv = context.watch<GalleryProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => _showEditStatsDialog(context),
            tooltip: 'Edit Community Stats',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.primary),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await auth.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              }
            },
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Events', icon: Icon(Icons.event)),
            Tab(text: 'Members', icon: Icon(Icons.group)),
            Tab(text: 'Gallery', icon: Icon(Icons.video_library_outlined)),
            Tab(text: 'Contact Messages', icon: Icon(Icons.message)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(context, theme, events, prov),
                _buildMembersTab(context, theme, membersProv),
                _buildGalleryTab(context, theme, galleryProv),
                _buildContactsTab(context, theme),
              ],
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }

  Widget _buildEventsTab(BuildContext context, ThemeData theme,
      List<EventModel> events, EventsProvider prov) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events Management',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${events.length} total events',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              _HoverButton(
                onPressed: () => _showEventDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('New Event'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: prov.loading
                ? const Center(child: CircularProgressIndicator())
                : events.isEmpty
                    ? _emptyEventsState(context, theme)
                    : ListView.separated(
                        itemCount: events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) =>
                            _eventRow(context, events[i], theme),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Messages',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_contacts.length} messages',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              _HoverButton(
                onPressed: _fetchContacts,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loadingContacts
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? _emptyContactsState(context, theme)
                    : ListView.separated(
                        itemCount: _contacts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) =>
                            _contactCard(context, _contacts[i], theme),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(
      BuildContext context, ThemeData theme, MembersProvider membersProv) {
    final members = membersProv.members;
    final activeMembers = members.where((m) => m.isActive).length;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isSmall
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Members Management',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$activeMembers active / ${members.length} total',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _HoverButton(
                          onPressed: () => membersProv.fetchMembers(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          isSmall: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HoverButton(
                            onPressed: () => _showMemberForm(context),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add Member'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Members Management',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$activeMembers active / ${members.length} total',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _HoverButton(
                          onPressed: () => membersProv.fetchMembers(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          isSmall: true,
                        ),
                        const SizedBox(width: 12),
                        _HoverButton(
                          onPressed: () => _showMemberForm(context),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Add Member'),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          Expanded(
            child: membersProv.loading
                ? const Center(child: CircularProgressIndicator())
                : members.isEmpty
                    ? _emptyMembersState(context, theme)
                    : ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) =>
                            _memberCard(context, members[i], theme, isMobile: isSmall),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(
      BuildContext context, ThemeData theme, GalleryProvider galleryProv) {
    final items = galleryProv.items;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isSmall
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gallery Management',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${items.length} cards',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _HoverButton(
                          onPressed: galleryProv.fetchGallery,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          isSmall: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HoverButton(
                            onPressed: () => _showGalleryForm(context),
                            icon: const Icon(Icons.add_to_photos_outlined),
                            label: const Text('New Card'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gallery Management',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${items.length} cards',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _HoverButton(
                          onPressed: galleryProv.fetchGallery,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          isSmall: true,
                        ),
                        const SizedBox(width: 12),
                        _HoverButton(
                          onPressed: () => _showGalleryForm(context),
                          icon: const Icon(Icons.add_to_photos_outlined),
                          label: const Text('New Card'),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          Expanded(
            child: galleryProv.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Text(
                          'No gallery cards yet. Create your first one!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) =>
                            _galleryAdminCard(context, items[i], theme),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyEventsState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text('No events yet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Create your first event to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          _HoverButton(
            onPressed: () => _showEventDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _emptyContactsState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text('No messages yet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Contact messages will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMembersState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text('No members yet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Add members to showcase your leadership team',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          _HoverButton(
            onPressed: () => _showMemberForm(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  Widget _eventRow(BuildContext context, EventModel e, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: e.imageUrl != null
              ? Image.network(
                  e.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.event, color: Colors.white),
                  ),
                )
              : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                  ),
                  child: const Icon(Icons.event, color: Colors.white),
                ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (e.isFeatured) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⭐ Featured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(e.formattedDateShort),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.location,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HoverIconButton(
              icon: Icons.edit,
              color: theme.colorScheme.primary,
              onPressed: () => _showEventDialog(context, editEventId: e.id),
              tooltip: 'Edit',
            ),
            const SizedBox(width: 8),
            _HoverIconButton(
              icon: Icons.delete,
              color: Colors.red,
              onPressed: () => _confirmDelete(context, e, theme),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
      BuildContext context, Map<String, dynamic> contact, ThemeData theme) {
    final name = contact['name'] as String? ?? 'Unknown';
    final email = contact['email'] as String? ?? '';
    final phone = contact['phone'] as String? ?? '';
    final message = contact['message'] as String? ?? '';
    final type = contact['type'] as String? ?? 'General';
    final createdAt = contact['created_at'] as String?;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email,
                            size: 14, color: theme.colorScheme.tertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 14, color: theme.colorScheme.tertiary),
                          const SizedBox(width: 6),
                          Text(phone, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (createdAt != null)
                Expanded(
                  child: Text(
                    'Received: ${DateTime.parse(createdAt).toString().split('.').first}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              _HoverButton(
                onPressed: () => _replyViaEmail(email, name),
                icon: const Icon(Icons.reply),
                label: const Text('Reply via Email'),
                isSmall: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _replyViaEmail(String email, String name) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Re: Your message to AWS Cloud Club&body=Hi $name,\n\n',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  Future<void> _launchExternalLink(String url) async {
    if (url.trim().isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link')),
        );
      }
      return;
    }
    if (!await canLaunchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link')),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _toggleMemberStatus(MemberModel member, bool isActive) async {
    try {
      await context
          .read<MembersProvider>()
          .updateMemberFields(member.id, {'is_active': isActive});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${member.name} is now ${isActive ? 'visible' : 'hidden'}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _memberCard(
      BuildContext context, MemberModel member, ThemeData theme,
      {required bool isMobile}) {
    final socialLinks = [
      {
        'icon': Icons.business_center,
        'url': member.linkedinUrl,
        'label': 'LinkedIn'
      },
      {'icon': Icons.code, 'url': member.githubUrl, 'label': 'GitHub'},
      {
        'icon': Icons.camera_alt, // Changed icon
        'url': member.instagramUrl, // Changed field
        'label': 'Instagram' // Changed label
      },
      // {'icon': Icons.public, 'url': member.websiteUrl, 'label': 'Website'}, // Removed
    ].where((item) {
      final url = item['url'] as String?;
      return url != null && url.trim().isNotEmpty;
    }).toList();

    final hasImage = member.profileUrl != null && member.profileUrl!.isNotEmpty; // Changed field

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasImage
                            ? null
                            : LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.tertiary,
                                ],
                              ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? Image.network(
                              member.profileUrl!, // Changed field
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatarFallback(theme, member),
                            )
                          : _avatarFallback(theme, member),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.role,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.email,
                        size: 16, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        member.email,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (member.bio != null && member.bio!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    member.bio!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: member.isActive
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        member.isActive ? 'Active' : 'Hidden',
                        style: TextStyle(
                          color: member.isActive
                              ? theme.colorScheme.primary
                              : Colors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch.adaptive(
                          value: member.isActive,
                          onChanged: (value) =>
                              _toggleMemberStatus(member, value),
                          activeColor: theme.colorScheme.primary,
                        ),
                        _HoverIconButton(
                          icon: Icons.edit,
                          color: theme.colorScheme.primary,
                          onPressed: () =>
                              _showMemberForm(context, member: member),
                          tooltip: 'Edit member',
                        ),
                        _HoverIconButton(
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onPressed: () =>
                              _confirmDeleteMember(context, member, theme),
                          tooltip: 'Delete member',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasImage
                        ? null
                        : LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasImage
                      ? Image.network(
                          member.profileUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _avatarFallback(theme, member),
                        )
                      : _avatarFallback(theme, member),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: member.isActive
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              member.isActive ? 'Active' : 'Hidden',
                              style: TextStyle(
                                color: member.isActive
                                    ? theme.colorScheme.primary
                                    : Colors.orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.role,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email,
                              size: 16, color: theme.colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              member.email,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (member.bio != null &&
                          member.bio!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          member.bio!.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.75),
                          ),
                        ),
                      ],
                      // if (member.skills.isNotEmpty) ...[
                      //   const SizedBox(height: 12),
                      //   Wrap(
                      //     spacing: 8,
                      //     runSpacing: 8,
                      //     children: member.skills
                      //         .map((skill) => Container(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 10, vertical: 6),
                      //               decoration: BoxDecoration(
                      //                 color: theme.colorScheme.primary
                      //                     .withOpacity(0.08),
                      //                 borderRadius: BorderRadius.circular(12),
                      //               ),
                      //               child: Text(
                      //                 skill,
                      //                 style:
                      //                     theme.textTheme.bodySmall?.copyWith(
                      //                   color: theme.colorScheme.primary,
                      //                   fontWeight: FontWeight.w600,
                      //                 ),
                      //               ),
                      //             ))
                      //         .toList(),
                      //   ),
                      // ],
                      if (socialLinks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: socialLinks
                              .map(
                                (item) => Tooltip(
                                  message: item['label'] as String,
                                  child: IconButton(
                                    icon: Icon(item['icon'] as IconData),
                                    color: theme.colorScheme.primary,
                                    onPressed: () => _launchExternalLink(
                                        item['url'] as String? ?? ''),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Joined: ${member.createdAt.toLocal().toString().split('.').first}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch.adaptive(
                          value: member.isActive,
                          onChanged: (value) =>
                              _toggleMemberStatus(member, value),
                          activeColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        _HoverIconButton(
                          icon: Icons.edit,
                          color: theme.colorScheme.primary,
                          onPressed: () =>
                              _showMemberForm(context, member: member),
                          tooltip: 'Edit member',
                        ),
                        const SizedBox(width: 8),
                        _HoverIconButton(
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onPressed: () =>
                              _confirmDeleteMember(context, member, theme),
                          tooltip: 'Delete member',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _galleryAdminCard(
      BuildContext context, GalleryItem item, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.cardColor,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 90,
            height: 60,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.monthYear,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            if (item.description != null && item.description!.trim().isNotEmpty)
              Text(
                item.description!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'Order: ${item.displayOrder} • ${item.isActive ? 'Visible' : 'Hidden'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HoverIconButton(
              icon: Icons.edit_outlined,
              color: theme.colorScheme.primary,
              onPressed: () => _showGalleryForm(context, item: item),
              tooltip: 'Edit',
            ),
            const SizedBox(width: 8),
            _HoverIconButton(
              icon: Icons.delete_outline,
              color: Colors.red,
              onPressed: () => _confirmDeleteGallery(context, item, theme),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme, MemberModel member) {
    return Container(
      color: theme.colorScheme.primary,
      child: Center(
        child: Text(
          member.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _showGalleryForm(BuildContext context,
      {GalleryItem? item}) async {
    final isEditing = item != null;
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final monthYearCtrl = TextEditingController(text: item?.monthYear ?? '');
    final orderCtrl = TextEditingController(
        text: item != null ? item.displayOrder.toString() : '0');
    bool isActive = item?.isActive ?? true;
    bool saving = false;
    XFile? pickedImage;

    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEditing ? 'Edit Gallery Card' : 'New Gallery Card'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (file != null) {
                            setState(() => pickedImage = file);
                          }
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: Text(
                          pickedImage != null
                              ? 'Image selected (${pickedImage!.name})'
                              : (item?.imageUrl != null &&
                                      item!.imageUrl.isNotEmpty
                                  ? 'Change image'
                                  : 'Choose image'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: monthYearCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Month & Year (e.g. May 2025)',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: orderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Display Order',
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      title: const Text('Visible in public gallery'),
                      subtitle:
                          const Text('Turn off to temporarily hide this card'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => saving = true);
                        try {
                          if (!isEditing && pickedImage == null) {
                            throw Exception(
                                'Please choose an image for this card.');
                          }
                          final order =
                              int.tryParse(orderCtrl.text.trim()) ?? 0;
                          final prov = context.read<GalleryProvider>();
                          if (isEditing) {
                            await prov.updateItem(
                              item.id,
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim().isEmpty
                                  ? null
                                  : descCtrl.text.trim(),
                              imageFile: pickedImage,
                              existingImageUrl: item.imageUrl,
                              monthYear: monthYearCtrl.text.trim(),
                              displayOrder: order,
                              isActive: isActive,
                            );
                          } else {
                            await prov.addItem(
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim().isEmpty
                                  ? null
                                  : descCtrl.text.trim(),
                              imageFile: pickedImage,
                              monthYear: monthYearCtrl.text.trim(),
                              displayOrder: order,
                              isActive: isActive,
                            );
                          }
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing
                                    ? 'Gallery card updated'
                                    : 'Gallery card created'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => saving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Save' : 'Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteGallery(
      BuildContext context, GalleryItem item, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete gallery card?'),
        content: Text(
            'Are you sure you want to delete "${item.title}" from gallery?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<GalleryProvider>().deleteItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gallery card deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberForm(BuildContext context,
      {MemberModel? member}) async {
    final isEditing = member != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: member?.name ?? '');
    final roleCtrl = TextEditingController(text: member?.role ?? '');
    final emailCtrl = TextEditingController(text: member?.email ?? '');
    final avatarCtrl = TextEditingController(text: member?.avatar ?? '');
    final bioCtrl = TextEditingController(text: member?.bio ?? '');
    final linkedinCtrl = TextEditingController(text: member?.linkedinUrl ?? '');
    final githubCtrl = TextEditingController(text: member?.githubUrl ?? '');
    final instagramCtrl = TextEditingController(text: member?.instagramUrl ?? '');
    final displayOrderCtrl = TextEditingController(
        text: member != null ? member.displayOrder.toString() : '0');
    bool isActive = member?.isActive ?? true;
    String category = member?.category ?? 'Member';
    bool saving = false;
    XFile? pickedImage;

    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEditing ? 'Edit Member' : 'Add Member'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => CustomImageCropper(
                              imageBytes: bytes,
                              onCancel: () => Navigator.pop(context),
                              onCropped: (croppedBytes) async {
                                final tempFile = XFile.fromData(croppedBytes);
                                setState(() => pickedImage = tempFile);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                        image: pickedImage != null
                            ? DecorationImage(
                                image: NetworkImage(pickedImage!.path),
                                fit: BoxFit.cover,
                              )
                            : (member?.profileUrl != null &&
                                    member!.profileUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(member.profileUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: pickedImage == null &&
                              (member?.profileUrl == null ||
                                  member!.profileUrl!.isEmpty)
                          ? Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select profile image',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Member Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Lead', child: Text('Core Lead')),
                      DropdownMenuItem(value: 'Member', child: Text('Member')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role / Title',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Role is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: avatarCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Avatar initials (optional)',
                      prefixIcon: Icon(Icons.font_download),
                    ),
                    maxLength: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bio / Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: linkedinCtrl,
                    decoration: const InputDecoration(
                      labelText: 'LinkedIn URL',
                      prefixIcon: Icon(Icons.business_center),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: githubCtrl,
                    decoration: const InputDecoration(
                      labelText: 'GitHub URL',
                      prefixIcon: Icon(Icons.code),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: instagramCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Instagram URL',
                      prefixIcon: Icon(Icons.camera_alt),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: displayOrderCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Display Order',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    title: const Text('Visible on members page'),
                    subtitle: const Text('Disable to hide without deleting'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => saving = true);
                        try {
                          final avatar = avatarCtrl.text.trim();
                          final bio = bioCtrl.text.trim();
                          final linkedin = linkedinCtrl.text.trim();
                          final github = githubCtrl.text.trim();
                          final instagram = instagramCtrl.text.trim();
                          final order =
                              int.tryParse(displayOrderCtrl.text.trim()) ?? 0;
                          final membersProv = context.read<MembersProvider>();
                          if (isEditing) {
                            await membersProv.updateMember(
                              member.id,
                              name: nameCtrl.text.trim(),
                              role: roleCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              avatar: avatar.isEmpty ? null : avatar,
                              profileUrl: member.profileUrl,
                              imageFile: pickedImage,
                              bio: bio.isEmpty ? null : bio,
                              linkedinUrl: linkedin.isEmpty ? null : linkedin,
                              githubUrl: github.isEmpty ? null : github,
                              instagramUrl: instagram.isEmpty ? null : instagram,
                              displayOrder: order,
                              isActive: isActive,
                              category: category,
                            );
                          } else {
                            await membersProv.addMember(
                              name: nameCtrl.text.trim(),
                              role: roleCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              avatar: avatar.isEmpty ? null : avatar,
                              imageFile: pickedImage,
                              bio: bio.isEmpty ? null : bio,
                              linkedinUrl: linkedin.isEmpty ? null : linkedin,
                              githubUrl: github.isEmpty ? null : github,
                              instagramUrl: instagram.isEmpty ? null : instagram,
                              displayOrder: order,
                              isActive: isActive,
                              category: category,
                            );
                          }
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing
                                    ? 'Member updated successfully'
                                    : 'Member added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => saving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteMember(
      BuildContext context, MemberModel member, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Member?'),
        content: Text(
            'Are you sure you want to remove "${member.name}" from the members list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<MembersProvider>().deleteMember(member.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Member removed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EventModel e, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Event?'),
        content: Text(
            'Are you sure you want to delete "${e.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final prov = context.read<EventsProvider>();
              try {
                await prov.deleteEvent(e.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;
  final bool isSmall;

  const _HoverButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isSmall = false,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: widget.icon,
          label: widget.label,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered
                ? theme.colorScheme.primary.withOpacity(0.9)
                : theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSmall ? 16 : 24,
              vertical: widget.isSmall ? 12 : 16,
            ),
            elevation: _isHovered ? 6 : 2,
          ),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _HoverIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: IconButton(
            icon: Icon(widget.icon),
            color: widget.color,
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }
}
