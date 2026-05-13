import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Refresh state saat kembali dari edit profil
  String _displayName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _displayName = user?.displayName ?? 'Pengguna';
      _email = user?.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Avatar & Name ──────────────────────────────────────
              Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.lightGreen,
                    child: Text(
                      _displayName.isNotEmpty
                          ? _displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_displayName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(_email,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textGrey)),
                ],
              ),

              const SizedBox(height: 24),

              // ── Stats ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsRow(userId: widget.userId),
              ),

              const SizedBox(height: 24),

              // ── Menu Items ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        );
                        // Refresh nama jika ada perubahan
                        if (changed == true) _loadUser();
                      },
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Pengaturan Notifikasi',
                      onTap: () => _showSnackbar(context, 'Segera hadir'),
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Setelan Aplikasi',
                      onTap: () => _showSnackbar(context, 'Segera hadir'),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privasi & Keamanan',
                      onTap: () => _showSnackbar(context, 'Segera hadir'),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Bantuan & FAQ',
                      onTap: () => _showSnackbar(context, 'Segera hadir'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Logout ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.statusCritical
                              .withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text('Keluar',
                          style: TextStyle(
                              color: AppTheme.statusCritical,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar',
                  style: TextStyle(color: AppTheme.statusCritical))),
        ],
      ),
    );
    if (confirm == true) await AuthService().logout();
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final String userId;
  const _StatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bahan tersimpan
        Expanded(
          child: StreamBuilder(
            stream: FirestoreService().getFoodStream(userId),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _StatBox(value: '$count', label: 'Bahan Tersimpan');
            },
          ),
        ),
        Container(width: 1, height: 50, color: AppTheme.dividerColor),
        // Resep dibuat
        Expanded(
          child: StreamBuilder(
            stream: FirestoreService().getRecipeLogStream(userId),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _StatBox(value: '$count', label: 'Resep Dibuat');
            },
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

// ── Menu Item ────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textDark, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark)),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.textGrey, size: 20),
          ],
        ),
      ),
    );
  }
}
