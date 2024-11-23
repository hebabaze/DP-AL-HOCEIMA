// lib/utils/contact_options.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactOptions {
  static void show(BuildContext context, String name, String mobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Pour que le bottom sheet prenne toute la hauteur si nécessaire
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre avec séparateur
              Center(
                child: Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 60,
                      height: 2,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Option Appeler
              ListTile(
                leading: const Icon(Icons.call, color: Colors.green),
                title: const Text("Appeler"),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall(mobile);
                },
              ),
              // Option WhatsApp
              ListTile(
                leading: Image.asset(
                  'assets/images/wtsp.png',
                  height: 24,
                  width: 24,
                ),
                title: const Text("WhatsApp"),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(mobile);
                },
              ),
              // Option Copier le numéro
              ListTile(
                leading: const Icon(Icons.content_copy, color: Colors.orange),
                title: const Text("Copier le numéro"),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, mobile);
                },
              ),
              const SizedBox(height: 10),
              // Bouton Fermer
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300, // Fond rouge doux
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Fermer",
                  style: TextStyle(
                    color: Colors.white, // Texte en blanc pour contraste
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    launchUrl(url);
  }

  static void _openWhatsApp(String phoneNumber) async {
    final Uri url = Uri.parse("https://wa.me/212${phoneNumber.substring(1)}");
    launchUrl(url);
  }

  static void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم نسخ الرقم إلى الحافظة")),
    );
  }
}
