// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../providers/app_state_provider.dart' as appstate;
import '../../widgets/admin_scaffold.dart';
import 'dart:math';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _showUserForm = false;
  User? _editingUser;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Ensure user data is loaded when screen opens
    // ignore: use_build_context_synchronously
    Future.microtask(() => context.read<UserProvider>().initialize());
  }

  void _openAddUser() {
    setState(() {
      _editingUser = null;
      _showUserForm = true;
    });
  }
  void _openEditUser(User user) {
    setState(() {
      _editingUser = user;
      _showUserForm = true;
    });
  }
  void _closeUserForm() {
    setState(() {
      _showUserForm = false;
      _editingUser = null;
      _isSaving = false;
    });
  }
  Future<void> _saveUser(User user) async {
    setState(() => _isSaving = true);
    final userProvider = context.read<UserProvider>();
    try {
      if (_editingUser == null) {
        await userProvider.createUser(user);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User added successfully'), backgroundColor: Colors.green));
      } else {
        await userProvider.updateUser(user);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User updated successfully'), backgroundColor: Colors.green));
      }
      _closeUserForm();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      setState(() => _isSaving = false);
    }
  }
  Future<void> _deleteUser(User user) async {
    final userProvider = context.read<UserProvider>();
    await showDeleteUserDialog(context, name: user.fullName, onDelete: () async {
      try {
        await userProvider.deleteUser(user.id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User deleted'), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    });
  }
  Future<void> _bulkDeleteUsers(List<User> users) async {
    final userProvider = context.read<UserProvider>();
    await showBulkDeleteDialog(context, users.length, () async {
      try {
        await userProvider.bulkDelete(users.map((u) => u.id).toList());
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${users.length} users'), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<appstate.AppStateProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return AdminScaffold(
      breadcrumbs: ['Dashboard', 'User Management'],
      selectedIndex: appState.selectedAdminTab,
      userRole: appState.userRole,
      onDestinationSelected: (index) {
        final appState = Provider.of<appstate.AppStateProvider>(context, listen: false);
        appState.setSelectedAdminTab(index);
        
        // Admin users have access to all tabs including User Management
        switch (index) {
          case 0:
            appState.setScreen(appstate.AppScreen.staffDashboard);
            break;
          case 1:
            appState.setScreen(appstate.AppScreen.articleManagement);
            break;
          case 2:
            appState.setScreen(appstate.AppScreen.userManagement);
            break;
          case 3:
            appState.setScreen(appstate.AppScreen.analytics);
            break;
        }
      },
      userName: 'Staff',
      userEmail: null,
      onLogout: () {
        final appState = Provider.of<appstate.AppStateProvider>(context, listen: false);
        appState.setRole(appstate.UserRole.reader);
        appState.setScreen(appstate.AppScreen.welcome);
      },
      floatingActionButton: _UserFAB(onAdd: _openAddUser),
      child: Stack(
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
              }
              if (userProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: [
                      Icon(
                        Icons.error_outline_rounded, 
                        size: isSmallMobile ? 48 : 64, 
                        color: AppColors.textSecondary.withOpacity(0.5)
                      ),
                      SizedBox(height: isSmallMobile ? 12 : 16),
                      Text(
                        'Error loading users', 
                        style: GoogleFonts.poppins(
                          fontSize: isSmallMobile ? 16 : (isMobile ? 17 : 18), 
                          fontWeight: FontWeight.w600, 
                          color: AppColors.textPrimary
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallMobile ? 6 : 8),
                      Text(
                        userProvider.error!, 
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: isSmallMobile ? 12 : 14,
                        ), 
                        textAlign: TextAlign.center
                      ),
                      SizedBox(height: isSmallMobile ? 12 : 16),
                      ElevatedButton(
                        onPressed: () => userProvider.initialize(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallMobile ? 16 : 20,
                            vertical: isSmallMobile ? 10 : 12,
                          ),
                        ),
                        child: Text(
                          'Retry', 
                          style: GoogleFonts.poppins(
                            fontSize: isSmallMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          )
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _UserManagementBody(
                onEdit: _openEditUser,
                onDelete: _deleteUser,
                onBulkDelete: _bulkDeleteUsers,
              );
            },
          ),
          if (_showUserForm)
            Center(
              child: _UserFormModal(
                user: _editingUser,
                onSave: _saveUser,
                onCancel: _closeUserForm,
                isLoading: _isSaving,
              ),
            ),
        ],
      ),
    );
  }
}

class _UserManagementBody extends StatelessWidget {
  final void Function(User user) onEdit;
  final void Function(User user) onDelete;
  final void Function(List<User> users) onBulkDelete;
  const _UserManagementBody({Key? key, required this.onEdit, required this.onDelete, required this.onBulkDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    return Padding(
      padding: EdgeInsets.all(isSmallMobile ? 12 : (screenWidth < 600 ? 16 : 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserManagementHeader(onBulkDelete: onBulkDelete),
          SizedBox(height: isSmallMobile ? 12 : 20),
          _UserTable(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _UserManagementHeader extends StatelessWidget {
  final void Function(List<User> users) onBulkDelete;
  const _UserManagementHeader({Key? key, required this.onBulkDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Column(
      children: [
        Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: userProvider.setSearchQuery,
                style: GoogleFonts.poppins(fontSize: isSmallMobile ? 12 : (isMobile ? 13 : 15)),
            decoration: InputDecoration(
              hintText: 'Search users...',
                  prefixIcon: Icon(
                    Icons.search_rounded, 
                    color: AppColors.secondary,
                    size: isSmallMobile ? 20 : 24,
                  ),
              border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.background,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isSmallMobile ? 8 : (isMobile ? 10 : 16),
                    horizontal: isSmallMobile ? 8 : (isMobile ? 10 : 16),
            ),
          ),
        ),
            ),
            SizedBox(width: isSmallMobile ? 8 : 16),
        if (userProvider.selectedUserIds.isNotEmpty)
          _BulkActionsMenu(onBulkDelete: onBulkDelete),
          ],
        ),
      ],
    );
  }
}

class _UserTable extends StatelessWidget {
  final void Function(User user) onEdit;
  final void Function(User user) onDelete;
  const _UserTable({Key? key, required this.onEdit, required this.onDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.filteredUsers;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isSmallMobile ? 20 : 40),
          child: Text(
            'No users found.', 
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 14 : 16, 
              color: AppColors.textSecondary
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: users.length,
        // ignore: unnecessary_underscores
        separatorBuilder: (_, __) => SizedBox(height: isSmallMobile ? 8 : 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final selected = userProvider.selectedUserIds.contains(user.id);
          return _UserCard(user: user, selected: selected, onEdit: onEdit, onDelete: onDelete);
        },
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  final User user;
  final bool selected;
  final void Function(User user) onEdit;
  final void Function(User user) onDelete;
  const _UserCard({required this.user, required this.selected, required this.onEdit, required this.onDelete});
  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 22),
          color: widget.selected ? AppColors.secondary.withOpacity(0.10) : AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovered ? 0.13 : 0.07),
              blurRadius: _hovered ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: widget.selected ? AppColors.secondary : Colors.transparent,
            width: isSmallMobile ? 1.5 : 2,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(isSmallMobile ? 6 : 16),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: isSmallMobile ? 16 : 24,
                backgroundColor: widget.user.status == UserStatus.active
                ? Colors.green.withOpacity(0.15)
                    : widget.user.status == UserStatus.suspended
                    ? Colors.red.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.15),
                child: widget.user.profilePicture != null
                    ? ClipOval(
                        child: Image.network(
                          widget.user.profilePicture!,
                          width: isSmallMobile ? 28 : 40,
                          height: isSmallMobile ? 28 : 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _InitialsAvatar(name: widget.user.fullName),
                        ),
                      )
                    : _InitialsAvatar(name: widget.user.fullName),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Tooltip(
                  message: _getStatusText(widget.user.status),
                  child: Container(
                    width: isSmallMobile ? 8 : 14,
                    height: isSmallMobile ? 8 : 14,
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.user.status),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: isSmallMobile ? 1.0 : 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.user.fullName, 
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallMobile ? 13 : (isMobile ? 14 : 16),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: isSmallMobile ? 4 : 8),
              Tooltip(
                message: _getRoleText(widget.user.role),
                child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallMobile ? 6 : 8, 
                        vertical: isSmallMobile ? 1 : 2
                      ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(widget.user.role).withOpacity(0.13),
                        borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
          ),
                  child: Text(
                    _getRoleText(widget.user.role),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallMobile ? 9 : 11, 
                          fontWeight: FontWeight.w600, 
                          color: _getRoleColor(widget.user.role)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.email, 
                style: GoogleFonts.poppins(
                  fontSize: isSmallMobile ? 11 : 13, 
                  color: AppColors.textSecondary
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallMobile ? 1 : 2),
              if (!isSmallMobile) ...[
              Row(
                children: [
                  Icon(Icons.phone_rounded, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.user.contactInfo, 
                        style: GoogleFonts.poppins(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Icon(Icons.lock_rounded, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.user.permissions.join(', '), 
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallMobile ? 1 : 2),
                Text(
                  'Last login: ${widget.user.lastLogin != null ? _formatDate(widget.user.lastLogin!) : 'Never'}', 
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)
                ),
              ] else ...[
                Text(
                  widget.user.contactInfo, 
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
                  children: [
              Checkbox(
                value: widget.selected,
                onChanged: (val) => userProvider.selectUser(widget.user.id, val ?? false),
                activeColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                ),
              if (isMobile) ...[
                // 3-dot menu for mobile devices
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded, 
                    size: isSmallMobile ? 18 : 20,
                    color: AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.all(isSmallMobile ? 2 : 4),
                  constraints: BoxConstraints(
                    minWidth: isSmallMobile ? 28 : 32,
                    minHeight: isSmallMobile ? 28 : 32,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEdit(widget.user);
                    } else if (value == 'delete') {
                      widget.onDelete(widget.user);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded, 
                            color: AppColors.primary, 
                            size: isSmallMobile ? 14 : 16
                          ),
                          SizedBox(width: isSmallMobile ? 6 : 8),
                          Text(
                            'Edit User', 
                            style: GoogleFonts.poppins(
                              fontSize: isSmallMobile ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded, 
                            color: Colors.red, 
                            size: isSmallMobile ? 14 : 16
                          ),
                          SizedBox(width: isSmallMobile ? 6 : 8),
                          Text(
                            'Delete User', 
                            style: GoogleFonts.poppins(
                              fontSize: isSmallMobile ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Hover-based buttons for larger screens
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit_rounded, size: isMobile ? 18 : 24),
                      tooltip: 'Edit',
                      color: AppColors.primary,
                      onPressed: () => widget.onEdit(widget.user),
                    ),
                    IconButton(
                        icon: Icon(Icons.delete_rounded, size: isMobile ? 18 : 24),
                      tooltip: 'Delete',
                      color: Colors.red,
                      onPressed: () => widget.onDelete(widget.user),
                    ),
                  ],
                ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.inactive:
        return Colors.grey;
    }
  }
  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.inactive:
        return 'Inactive';
    }
  }
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.primary;
      case UserRole.editor:
        return Colors.purple;
      case UserRole.writer:
        return Colors.teal;
      default:
        return AppColors.secondary;
    }
  }
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.editor:
        return 'Editor';
      case UserRole.writer:
        return 'Writer';
      default:
        return 'User';
    }
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '';
    return Text(
      initials, 
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold, 
        fontSize: isSmallMobile ? 10 : 16, 
        color: AppColors.primary
      )
    );
  }
}

class _BulkActionsMenu extends StatelessWidget {
  final void Function(List<User> users) onBulkDelete;
  const _BulkActionsMenu({Key? key, required this.onBulkDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded, 
        color: AppColors.secondary,
        size: isSmallMobile ? 20 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12)),
      onSelected: (value) async {
        if (value == 'delete') {
          final users = userProvider.users.where((u) => userProvider.selectedUserIds.contains(u.id)).toList();
          onBulkDelete(users);
        } else if (value == 'role') {
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_rounded, 
                color: Colors.red, 
                size: isSmallMobile ? 16 : 20
              ),
              SizedBox(width: isSmallMobile ? 6 : 8),
              Text(
                'Bulk Delete', 
                style: GoogleFonts.poppins(
                  fontSize: isSmallMobile ? 12 : 14,
                )
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'role',
          child: Row(
            children: [
              Icon(
                Icons.person_rounded, 
                color: AppColors.primary, 
                size: isSmallMobile ? 16 : 20
              ),
              SizedBox(width: isSmallMobile ? 6 : 8),
              Text(
                'Bulk Role Change', 
                style: GoogleFonts.poppins(
                  fontSize: isSmallMobile ? 12 : 14,
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserFAB extends StatelessWidget {
  final VoidCallback onAdd;
  const _UserFAB({Key? key, required this.onAdd}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    return FloatingActionButton.extended(
      backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onPrimary,
      onPressed: onAdd,
      icon: Icon(
        Icons.person_add_rounded, 
        size: isSmallMobile ? 20 : 24
      ),
      label: Text(
        'Add User', 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: isSmallMobile ? 12 : 14,
        )
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

// 1. Add User Form Modal
class _UserFormModal extends StatefulWidget {
  final User? user;
  final void Function(User user) onSave;
  final VoidCallback onCancel;
  final bool isLoading;
  const _UserFormModal({this.user, required this.onSave, required this.onCancel, this.isLoading = false});
  @override
  State<_UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<_UserFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _contactController;
  late TextEditingController _positionController;
  late TextEditingController _titleController;
  UserRole _role = UserRole.writer;
  UserStatus _status = UserStatus.active;
  List<String> _permissions = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _displayNameController = TextEditingController(text: widget.user?.displayName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _contactController = TextEditingController(text: widget.user?.contactInfo ?? '');
    _positionController = TextEditingController(text: widget.user?.position ?? '');
    _titleController = TextEditingController(text: widget.user?.title ?? '');
    _role = widget.user?.role ?? UserRole.writer;
    _status = widget.user?.status ?? UserStatus.active;
    _permissions = List.from(widget.user?.permissions ?? []);

  }
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _contactController.dispose();
    _positionController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  String _generatePassword([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 24)),
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxDialogWidth = isSmallMobile ? constraints.maxWidth * 0.95 : (isMobile ? constraints.maxWidth * 0.9 : (constraints.maxWidth * 0.8 > 700 ? 700 : constraints.maxWidth * 0.8));
          final double minDialogWidth = isSmallMobile ? constraints.maxWidth * 0.9 : (constraints.maxWidth < 350 ? constraints.maxWidth * 0.95 : 350);
          final double maxDialogHeight = constraints.maxHeight * (isSmallMobile ? 0.9 : 0.85);
          
          
          final double finalMaxWidth = maxDialogWidth;
          final double finalMinWidth = minDialogWidth < finalMaxWidth ? minDialogWidth : finalMaxWidth * 0.8;
          
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: finalMaxWidth,
                minWidth: finalMinWidth,
                maxHeight: maxDialogHeight,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 24)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxDialogHeight - (isSmallMobile ? 24 : 48), // Account for padding
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.user == null ? Icons.person_add_rounded : Icons.edit_rounded, 
                                  color: AppColors.secondary, 
                                  size: isSmallMobile ? 20 : (isMobile ? 24 : 28)
                                ),
                                SizedBox(width: isSmallMobile ? 6 : 12),
                                Expanded(
                                  child: Text(
                                    widget.user == null ? 'Add User' : 'Edit User', 
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 20), 
                                      fontWeight: FontWeight.bold, 
                                      color: AppColors.primary
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.onCancel, 
                                  icon: Icon(
                                    Icons.close_rounded, 
                                    color: AppColors.textSecondary,
                                    size: isSmallMobile ? 18 : 24,
                                  ),
                                  padding: EdgeInsets.all(isSmallMobile ? 4 : 8),
                                  constraints: BoxConstraints(
                                    minWidth: isSmallMobile ? 32 : 48,
                                    minHeight: isSmallMobile ? 32 : 48,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: isSmallMobile ? 12 : 16),
                            if (isSmallMobile) ...[
                              // Stack fields vertically on small mobile
                              TextFormField(
                                controller: _firstNameController,
                                style: GoogleFonts.poppins(fontSize: 11),
                                decoration: InputDecoration(
                                  labelText: 'First Name *', 
                                  prefixIcon: Icon(Icons.person_rounded, size: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  isDense: true,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'First name required';
                                  if (v.trim().length < 2) return 'First name must be at least 2 characters';
                                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) return 'First name can only contain letters';
                                  return null;
                                },
                              ),
                              SizedBox(height: 6),
                              TextFormField(
                                controller: _lastNameController,
                                style: GoogleFonts.poppins(fontSize: 11),
                                decoration: InputDecoration(
                                  labelText: 'Last Name *', 
                                  prefixIcon: Icon(Icons.person_rounded, size: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  isDense: true,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Last name required';
                                  if (v.trim().length < 2) return 'Last name must be at least 2 characters';
                                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) return 'Last name can only contain letters';
                                  return null;
                                },
                              ),
                            ] else ...[
                              // Row layout for larger screens
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                      decoration: InputDecoration(
                                        labelText: 'First Name *', 
                                        prefixIcon: Icon(Icons.person_rounded),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'First name required';
                                      if (v.trim().length < 2) return 'First name must be at least 2 characters';
                                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) return 'First name can only contain letters';
                                      return null;
                                    },
                                  ),
                                ),
                                  SizedBox(width: isMobile ? 8 : 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Last Name *', 
                                        prefixIcon: Icon(Icons.person_rounded),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Last name required';
                                      if (v.trim().length < 2) return 'Last name must be at least 2 characters';
                                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) return 'Last name can only contain letters';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            ],
                            SizedBox(height: isSmallMobile ? 6 : 12),
                            TextFormField(
                              controller: _displayNameController,
                              style: GoogleFonts.poppins(fontSize: isSmallMobile ? 11 : 14),
                              decoration: InputDecoration(
                                labelText: 'Display Name *', 
                                prefixIcon: Icon(Icons.badge_rounded, size: isSmallMobile ? 18 : 24),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 16)),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: isSmallMobile ? 6 : 12, 
                                  horizontal: isSmallMobile ? 8 : 12
                                ),
                                isDense: isSmallMobile,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Display name required';
                                if (v.trim().length < 3) return 'Display name must be at least 3 characters';
                                if (v.trim().length > 50) return 'Display name must be less than 50 characters';
                                return null;
                              },
                            ),
                            SizedBox(height: isSmallMobile ? 6 : 12),
                            TextFormField(
                              controller: _emailController,
                              style: GoogleFonts.poppins(fontSize: isSmallMobile ? 11 : 14),
                              decoration: InputDecoration(
                                labelText: 'Email *', 
                                prefixIcon: Icon(Icons.email_rounded, size: isSmallMobile ? 18 : 24),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 16)),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: isSmallMobile ? 6 : 12, 
                                  horizontal: isSmallMobile ? 8 : 12
                                ),
                                isDense: isSmallMobile,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email required';
                                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!emailRegex.hasMatch(v.trim())) return 'Please enter a valid email address';
                                if (v.trim().length > 100) return 'Email must be less than 100 characters';
                                return null;
                              },
                            ),
                            SizedBox(height: isSmallMobile ? 6 : 12),
                            TextFormField(
                              controller: _contactController,
                              style: GoogleFonts.poppins(fontSize: isSmallMobile ? 11 : 14),
                              decoration: InputDecoration(
                                labelText: 'Contact Info *', 
                                prefixIcon: Icon(Icons.phone_rounded, size: isSmallMobile ? 18 : 24),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 16)),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: isSmallMobile ? 6 : 12, 
                                  horizontal: isSmallMobile ? 8 : 12
                                ),
                                isDense: isSmallMobile,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Contact info required';
                                final phoneRegex = RegExp(r'^(\+\d{1,3}[- ]?)?\d{10,}$');
                                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!phoneRegex.hasMatch(v.trim()) && !emailRegex.hasMatch(v.trim())) {
                                  return 'Please enter a valid phone number or email address';
                                }
                                if (v.trim().length > 50) return 'Contact info must be less than 50 characters';
                                return null;
                              },
                            ),
                            SizedBox(height: isSmallMobile ? 6 : 12),
                            DropdownButtonFormField<UserRole>(
                              value: _role,
                              style: GoogleFonts.poppins(fontSize: isSmallMobile ? 11 : 14),
                              items: UserRole.values.map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.name[0].toUpperCase() + role.name.substring(1)),
                              )).toList(),
                              onChanged: (v) => setState(() => _role = v!),
                              decoration: InputDecoration(
                                labelText: 'Role *', 
                                prefixIcon: Icon(Icons.security_rounded, size: isSmallMobile ? 18 : 24),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 16)),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: isSmallMobile ? 6 : 12, 
                                  horizontal: isSmallMobile ? 8 : 12
                                ),
                                isDense: isSmallMobile,
                              ),
                              validator: (v) => v == null ? 'Please select a role' : null,
                            ),
                            SizedBox(height: isSmallMobile ? 6 : 12),
                            DropdownButtonFormField<UserStatus>(
                              value: _status,
                              style: GoogleFonts.poppins(fontSize: isSmallMobile ? 11 : 14),
                              items: UserStatus.values.map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                              )).toList(),
                              onChanged: (v) => setState(() => _status = v!),
                              decoration: InputDecoration(
                                labelText: 'Status *', 
                                prefixIcon: Icon(Icons.verified_user_rounded, size: isSmallMobile ? 18 : 24),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 16)),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: isSmallMobile ? 6 : 12, 
                                  horizontal: isSmallMobile ? 8 : 12
                                ),
                                isDense: isSmallMobile,
                              ),
                              validator: (v) => v == null ? 'Please select a status' : null,
                            ),
                            SizedBox(height: isSmallMobile ? 8 : 12),
                            // Permissions (simple chips input)
                            FormField<List<String>>(
                              initialValue: _permissions,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please select at least one permission';
                                if (value.length > 5) return 'Maximum 5 permissions allowed';
                                return null;
                              },
                              builder: (state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Permissions *',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallMobile ? 11 : 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: isSmallMobile ? 4 : 8),
                                  Wrap(
                                    spacing: isSmallMobile ? 4 : 8,
                                    runSpacing: isSmallMobile ? 3 : 6,
                                    children: [
                                      'manage_users', 'edit_articles', 'publish_articles'
                                    ].map((perm) => FilterChip(
                                      label: Text(
                                        perm.replaceAll('_', ' '),
                                        style: GoogleFonts.poppins(fontSize: isSmallMobile ? 9 : 12),
                                      ),
                                      selected: _permissions.contains(perm),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) _permissions.add(perm);
                                          else _permissions.remove(perm);
                                        });
                                        state.didChange(_permissions);
                                      },
                                      backgroundColor: AppColors.background,
                                      selectedColor: AppColors.secondary.withOpacity(0.2),
                                      checkmarkColor: AppColors.secondary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 16),
                                        side: BorderSide(
                                          color: _permissions.contains(perm) ? AppColors.secondary : AppColors.secondary.withOpacity(0.3),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallMobile ? 6 : 8,
                                        vertical: isSmallMobile ? 2 : 4,
                                      ),
                                    )).toList(),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: EdgeInsets.only(top: isSmallMobile ? 4 : 6),
                                      child: Text(
                                        state.errorText!, 
                                        style: TextStyle(
                                          color: Colors.red, 
                                          fontSize: isSmallMobile ? 10 : 12
                                        )
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallMobile ? 12 : 24),
                            if (isSmallMobile) ...[
                              // Stack buttons vertically on small mobile
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.isLoading ? null : () {
                                    if (_formKey.currentState!.validate()) {
                                      final isNewUser = widget.user == null;
                                      final generatedPassword = isNewUser ? _generatePassword() : widget.user?.password;
                                      final user = User(
                                        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                        firstName: _firstNameController.text.trim(),
                                        lastName: _lastNameController.text.trim(),
                                        displayName: _displayNameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        username: _emailController.text.trim(),
                                        contactInfo: _contactController.text.trim(),
                                        role: _role,
                                        status: _status,
                                        permissions: _permissions,
                                        profilePicture: widget.user?.profilePicture,
                                        lastLogin: widget.user?.lastLogin ?? DateTime.now(),
                                        activityLogs: widget.user?.activityLogs ?? [],
                                        memberSince: widget.user?.memberSince ?? DateTime.now(),
                                        twoFactorEnabled: widget.user?.twoFactorEnabled ?? false,
                                        activeSessions: widget.user?.activeSessions ?? [],
                                        loginHistory: widget.user?.loginHistory ?? [],
                                        articlesPublished: widget.user?.articlesPublished ?? 0,
                                        totalViews: widget.user?.totalViews ?? 0,
                                        contributions: widget.user?.contributions ?? 0,
                                        password: generatedPassword,
                                      );
                                      widget.onSave(user);
                                      if (isNewUser) {
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          showDialog(
                                            // ignore: use_build_context_synchronously
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('User Created', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                              content: SelectableText('Generated password: $generatedPassword'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: AppColors.onPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: widget.isLoading
                                    ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary)))
                                    : Text(
                                        widget.user == null ? 'Add User' : 'Save Changes', 
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        )
                                      ),
                                ),
                              ),
                              SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: widget.isLoading ? null : widget.onCancel,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.secondary,
                                    side: BorderSide(color: AppColors.secondary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: Text(
                                    'Cancel', 
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    )
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Row layout for larger screens
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: widget.isLoading ? null : () {
                                    if (_formKey.currentState!.validate()) {
                                      final isNewUser = widget.user == null;
                                      final generatedPassword = isNewUser ? _generatePassword() : widget.user?.password;
                                      final user = User(
                                        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                        firstName: _firstNameController.text.trim(),
                                        lastName: _lastNameController.text.trim(),
                                        displayName: _displayNameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        username: _emailController.text.trim(),
                                        contactInfo: _contactController.text.trim(),
                                        role: _role,
                                        status: _status,
                                        permissions: _permissions,
                                        profilePicture: widget.user?.profilePicture,
                                        lastLogin: widget.user?.lastLogin ?? DateTime.now(),
                                        activityLogs: widget.user?.activityLogs ?? [],
                                        memberSince: widget.user?.memberSince ?? DateTime.now(),
                                        twoFactorEnabled: widget.user?.twoFactorEnabled ?? false,
                                        activeSessions: widget.user?.activeSessions ?? [],
                                        loginHistory: widget.user?.loginHistory ?? [],
                                        articlesPublished: widget.user?.articlesPublished ?? 0,
                                        totalViews: widget.user?.totalViews ?? 0,
                                        contributions: widget.user?.contributions ?? 0,
                                        password: generatedPassword,
                                      );
                                      widget.onSave(user);
                                      if (isNewUser) {
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          showDialog(
                                            // ignore: use_build_context_synchronously
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('User Created', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                              content: SelectableText('Generated password: $generatedPassword'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: AppColors.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 16 : 24, 
                                        vertical: isMobile ? 8 : 12
                                      ),
                                  ),
                                  child: widget.isLoading
                                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary)))
                                      : Text(
                                          widget.user == null ? 'Add User' : 'Save Changes', 
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isMobile ? 11 : 14,
                                          )
                                        ),
                                  ),
                                  SizedBox(width: isMobile ? 6 : 12),
                                OutlinedButton(
                                  onPressed: widget.isLoading ? null : widget.onCancel,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.secondary,
                                    side: BorderSide(color: AppColors.secondary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 16 : 24, 
                                        vertical: isMobile ? 8 : 12
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel', 
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 11 : 14,
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 2. Add Delete Confirmation Dialog
Future<bool?> showDeleteUserDialog(BuildContext context, {required String name, required VoidCallback onDelete}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallMobile = screenWidth < 400;
  
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20)),
      title: Text(
        'Delete User', 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: isSmallMobile ? 16 : 18,
        )
      ),
      content: Text(
        'Are you sure you want to delete "$name"? This action cannot be undone.', 
        style: GoogleFonts.poppins(fontSize: isSmallMobile ? 12 : 14)
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel', 
            style: GoogleFonts.poppins(fontSize: isSmallMobile ? 12 : 14)
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 10 : 12)),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 12 : 16,
              vertical: isSmallMobile ? 8 : 10,
            ),
          ),
          onPressed: () {
            onDelete();
            Navigator.of(context).pop(true);
          },
          child: Text(
            'Delete', 
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            )
          ),
        ),
      ],
    ),
  );
}

// 3. Add Bulk Delete Confirmation Dialog
Future<bool?> showBulkDeleteDialog(BuildContext context, int count, VoidCallback onDelete) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallMobile = screenWidth < 400;
  
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20)),
      title: Text(
        'Bulk Delete', 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: isSmallMobile ? 16 : 18,
        )
      ),
      content: Text(
        'Delete $count selected users? This cannot be undone.', 
        style: GoogleFonts.poppins(fontSize: isSmallMobile ? 12 : 14)
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel', 
            style: GoogleFonts.poppins(fontSize: isSmallMobile ? 12 : 14)
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 10 : 12)),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 12 : 16,
              vertical: isSmallMobile ? 8 : 10,
            ),
          ),
          onPressed: () {
            onDelete();
            Navigator.of(context).pop(true);
          },
          child: Text(
            'Delete', 
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            )
          ),
        ),
      ],
    ),
  );
} 