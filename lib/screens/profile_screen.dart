import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final path = await context.read<StorageService>().readProfilePhoto();
    if (mounted) setState(() => _photoPath = path);
  }

  Future<void> _takePhoto() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      final message = permission.isPermanentlyDenied
          ? 'Camera access is blocked. Enable it in Android Settings.'
          : 'Camera permission is needed to take a profile photo.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      if (permission.isPermanentlyDenied) await openAppSettings();
      return;
    }
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
    );
    if (image == null) return;
    if (!mounted) return;
    await context.read<StorageService>().saveProfilePhoto(image.path);
    setState(() => _photoPath = image.path);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage:
                  _photoPath != null && File(_photoPath!).existsSync()
                  ? FileImage(File(_photoPath!))
                  : null,
              child: _photoPath == null
                  ? const Icon(Icons.person, size: 64)
                  : null,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Take profile photo'),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    ),
  );
}
