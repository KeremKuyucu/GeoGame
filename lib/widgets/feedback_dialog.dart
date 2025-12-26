import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geogame/models/app_context.dart';
import 'package:geogame/services/localization_service.dart';

import 'package:geogame/widgets/custom_notification.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({Key? key}) : super(key: key);

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
        SnackBar(content: Text(Localization.get('boslukuyari'))),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      Navigator.pop(context);
      _showCustomNotification(
        Localization.get('hata_baslik'),
        Localization.get('giris_yap_mesaj'),
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
      Navigator.pop(context); // Başarılı olunca input diyaloğunu kapat

      _showCustomNotification(
        Localization.get('basarili_baslik'),
        Localization.get('feedback_gonderildi'),
      );
    } catch (e) {
      if (!mounted) return;
      // Hata durumunda diyaloğu kapatma, kullanıcı tekrar deneyebilsin
      setState(() => _isLoading = false);

      _showCustomNotification(
        Localization.get('hata_baslik'),
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // Klavye açılınca taşmayı önler
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localization.get('hatabildir'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _sebepController,
                Localization.get('hatabaslik'),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _messageController,
                Localization.get('hatametin'),
                maxLines: 3, // Mesaj kutusu biraz daha büyük olmalı
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // İptal Butonu
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 10),
                  // Gönder Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Gönder'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }
}