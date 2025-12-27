import 'package:flutter/material.dart';
import 'package:geogame/services/localization_service.dart';

class CustomNotification extends StatelessWidget {
  final String baslik;
  final String metin;

  const CustomNotification({
    super.key,
    required this.baslik,
    required this.metin,
  });

  // --- STATIC HELPER METHOD ---
  // Bu metot sayesinde uygulamanın herhangi bir yerinden tek satırda çağırabilirsin.
  // Kullanımı: CustomNotification.show(context, baslik: "Hata", metin: "Giriş başarısız");
  static void show(BuildContext context, {required String baslik, required String metin}) {
    showDialog(
      context: context,
      builder: (context) => CustomNotification(
        baslik: baslik,
        metin: metin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue, // İstersen Theme.of(context).primaryColor yapabilirsin
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              baslik,
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              metin,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Localization.t('common.ok'),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}