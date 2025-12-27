import 'package:flutter/material.dart';
import 'package:campus_grid/src/services/user_service.dart' as user_service;
import 'package:campus_grid/src/shared/widgets/text_field.dart';
import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userProfile;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _checkSignInMethod();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _checkSignInMethod() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      _isGoogleUser = user.providerData.first.providerId == 'google.com';
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      _userProfile = await user_service.getCurrentUserProfile();
      _displayNameController.text = _userProfile?['displayName'] ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await user_service.updateUserProfile(
        displayName: _displayNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showChangeEmailDialog() {
    final newEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                labelText: 'New Email',
                hintText: 'Enter new email',
                controller: newEmailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Current Password',
                hintText: 'Enter your password',
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'No verification link will be sent to your new email',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(context);
              setState(() => _isSaving = true);

              try {
                await user_service.updateUserEmail(
                  newEmailController.text.trim(),
                  currentPassword: passwordController.text,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email sent! Check your inbox.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _isSaving = false);
              }
            },
            child: const Text('Change Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: TextStyle(color: colors.primary)),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: 32, color: colors.primary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: colors.primary)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 32, color: colors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primary, width: 3),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Display Name Field
              CustomTextField(
                labelText: 'Display Name',
                hintText: 'Enter your name',
                controller: _displayNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a display name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Section
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withAlpha((0.7 * 255).toInt()),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.outline.withAlpha((0.3 * 255).toInt()),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _userProfile?['email'] ?? 'No email',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.onSurface.withAlpha((0.6 * 255).toInt()),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: colors.onSurface.withAlpha((0.5 * 255).toInt()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isGoogleUser
                          ? 'Email cannot be changed for Google accounts'
                          : 'Click button to change email',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withAlpha((0.5 * 255).toInt()),
                      ),
                    ),
                  ),
                  if (!_isGoogleUser)
                    TextButton.icon(
                      onPressed: _showChangeEmailDialog,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Change'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
