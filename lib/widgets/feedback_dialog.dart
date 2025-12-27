// lib/widgets/feedback_dialog.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';
import 'package:geogame/widgets/custom_notification.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  late final TextEditingController _sebepController;
  late final TextEditingController _messageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sebepController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _sebepController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final sebep = _sebepController.text.trim();
    final message = _messageController.text.trim();

    if (sebep.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Localization.t('common.field_required'))),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      Navigator.pop(context);
      _showCustomNotification(
        Localization.t('common.error'),
        Localization.t('auth.login_required'),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('feedbacks').insert({
        'sebep': sebep,
        'message': message,
        'isim': AppState.user.name,
        'user_id': user.id,
        'app': 'GeoGame',
      });

      if (!mounted) return;
      Navigator.pop(context);

      _showCustomNotification(
        Localization.t('common.success'),
        Localization.t('feedback.sent_success'),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showCustomNotification(
        Localization.t('common.error'),
        "Error: $e",
      );
    }
  }

  void _showCustomNotification(String baslik, String metin) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomNotification(
          baslik: baslik,
          metin: metin,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppState.settings.darkTheme;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localization.t('feedback.title'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _sebepController,
                Localization.t('feedback.subject_hint'),
                isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _messageController,
                Localization.t('feedback.message_hint'),
                isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(Localization.t('common.cancel')),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(Localization.t('common.send')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      ),
    );
  }
}