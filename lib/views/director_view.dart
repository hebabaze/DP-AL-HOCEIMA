import 'package:flutter/material.dart';
import 'package:dphoc/services/google_sheets_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
class DirectorView extends StatefulWidget {
  const DirectorView({Key? key}) : super(key: key);

  @override
  _DirectorViewState createState() => _DirectorViewState();
}

class _DirectorViewState extends State<DirectorView> {
  Map<String, dynamic>? directorData;
  bool isLoading = true;
  late GoogleSheetsService _sheetsService;

  @override
  void initState() {
    super.initState();
    _sheetsService = GoogleSheetsService();
    _loadDirectorData();
  }

  Future<void> _loadDirectorData() async {
    try {
      final data = await _sheetsService.loadData('services');
      setState(() {
        directorData = data.firstWhere(
          (contact) => contact['service'] == 'directeur',
          
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        directorData = null;
        isLoading = false;
      });
      log("Erreur lors du chargement des données du directeur : $e");
    }
  }

  void _makePhoneCall(String phoneNumber) {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    launchUrl(url);
  }

  void _openWhatsApp(String phoneNumber) {
    final Uri url = Uri.parse("https://wa.me/212${phoneNumber.substring(1)}");
    launchUrl(url);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم نسخ الرقم إلى الحافظة")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = 0.85 * screenWidth;
    const double fontSizeTitle = 24;
    const double fontSizeRole = 20;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("المدير الإقليمي",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (directorData == null || directorData!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("المدير الإقليمي",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: const Center(child: Text('Aucune donnée disponible.')),
      );
    }

    final String name = directorData!['Nom'] ?? 'غير متوفر';
    final String mobile = directorData!['mobile'] ?? 'غير متوفر';
    const String role = "المدير الإقليمي لمديرية الحسيمة";
    const String imageUrl =
        'assets/images/manager.png'; // Remplacez par directorData!['image_url'] si disponible

    return Scaffold(
      appBar: AppBar(
        title: const Text("المدير الإقليمي",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 103, 109, 115),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            // Carte mise à jour
            Container(
              width: cardWidth,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 167, 199, 215), Color.fromARGB(255, 15, 146, 207)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image mise à jour
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imageUrl,
                      width: 150,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "السيد $name",
                    style: const TextStyle(
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    role,
                    style: TextStyle(
                      fontSize: fontSizeRole,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Boutons mis à jour
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton Appeler
                ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(mobile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text(
                    "اتصال",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton WhatsApp
                ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(mobile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 228, 234, 234),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 5,
                  ),
                  icon: Image.asset(
                    'assets/images/wtsp.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  label: const Text(
                    "واتساب",
                    style: TextStyle(color: Color.fromARGB(255, 37, 36, 36), fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton Copier
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(mobile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.copy, color: Colors.white),
                  label: const Text(
                    "نسخ",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
