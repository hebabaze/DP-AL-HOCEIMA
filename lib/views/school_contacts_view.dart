// lib/views/school_contacts_view.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dphoc/services/google_sheets_service.dart'; // Import GoogleSheetsService
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class SchoolContactsView extends StatefulWidget {
  final String sheetName;
  final String title;
  final Color bgColor;
  final Color iconColor;

  const SchoolContactsView({
    Key? key,
    required this.sheetName,
    required this.title,
    required this.bgColor,
    required this.iconColor,
  }) : super(key: key);

  @override
  State<SchoolContactsView> createState() => _SchoolContactsViewState();
}

class _SchoolContactsViewState extends State<SchoolContactsView> {
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> filteredContacts = [];
  bool isLoading = true;
  String _searchQuery = ""; // Variable pour suivre la requête de recherche

  late GoogleSheetsService _sheetsService;

  @override
  void initState() {
    super.initState();
    _sheetsService = GoogleSheetsService(); // Initialisation du service
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final data = await _sheetsService.loadData(widget.sheetName); // Chargement des données depuis le stockage local
      setState(() {
        contacts = data;
        filteredContacts = List.from(contacts);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        contacts = [];
        filteredContacts = [];
        isLoading = false;
      });
      log("Error loading contacts: $e");
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query; // Mettre à jour la requête de recherche
      filteredContacts = contacts.where((contact) {
        final etab = contact["etab"]?.toString().toLowerCase() ?? ""; // Nom de l'établissement
        final nom = contact["nom"]?.toString().toLowerCase() ?? ""; // Nom du directeur
        final mobile = contact["mobile"]?.toString() ?? ""; // Numéro de téléphone

        return etab.contains(query.toLowerCase()) ||
               nom.contains(query.toLowerCase()) ||
               mobile.contains(query); // Filtrage basé sur la requête
      }).toList();
    });
  }

  IconData _getCycleIconBySheet(String sheetName) {
    switch (sheetName) {
      case "primaire":
        return Icons.menu_book; // Icône pour primaire
      case "college":
        return Icons.home_work_outlined; // Icône pour collège
      case "lycee":
        return Icons.school; // Icône pour lycée
      default:
        return Icons.block_rounded; // Icône par défaut
    }
  }

  void _showContactOptions(BuildContext context, String contactName, String mobile) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en cliquant en dehors
      barrierLabel: 'Contact Options',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink(); // Nécessaire mais non utilisé
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: _buildContactDialog(context, contactName, mobile),
          ),
        );
      },
    );
  }

Widget _buildContactDialog(BuildContext context, String contactName, String mobile) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), // Coins plus arrondis
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white,  Color.fromARGB(255, 189, 205, 101)], // Dégradé blanc à gris clair
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Alignement des boutons à gauche
        children: [
          // Titre avec séparateur
          Center(
            child: Column(
              children: [
                Text(
                  contactName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24, // Augmentation de la taille du texte
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Texte en noir
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 100,
                  height: 3,
                  color: const Color.fromARGB(255, 13, 16, 212), // Séparateur en noir
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Boutons alignés à gauche
          _buildAlignedButton(
            icon: Icons.call,
            label: "Appeler",
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 196, 206, 211), Color.fromARGB(48, 137, 182, 150)], // Bleu doux
            ),
            textColor: Colors.black, // Texte en noir
            onPressed: () {
              _makePhoneCall(mobile); // Fonctionnalité d'appel
            },
          ),
          const SizedBox(height: 10),
          _buildAlignedButton(
            label: "WhatsApp",
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 241, 231, 29), Color(0xFF81C784)], // Vert doux
            ),
            textColor: Colors.black, // Texte en noir
            onPressed: () {
              _openWhatsApp(mobile); // Fonctionnalité WhatsApp
            },
            iconImagePath: 'assets/images/wtsp.png', // Image personnalisée pour WhatsApp
          ),
          const SizedBox(height: 10),
          _buildAlignedButton(
            icon: Icons.copy,
            label: "Copier le numéro",
            gradient: const LinearGradient(
              colors: [Color(0xFFFFCCBC), Color(0xFFFFAB91)], // Orange clair
            ),
            textColor: Colors.black, // Texte en noir
            onPressed: () {
              _copyToClipboard(mobile); // Fonctionnalité de copie
            },
          ),
          const SizedBox(height: 20),
          // Bouton Fermer centré
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 250, 31, 31), // Fond rouge doux
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Réduction de la hauteur
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
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
          ),
        ],
      ),
    ),
  );
}

Widget _buildAlignedButton({
  IconData? icon,
  String? iconImagePath,
  required String label,
  required Gradient gradient,
  required Color textColor,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(10),
    ),
    child: MaterialButton(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ajuste la largeur pour couvrir le contenu uniquement
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconImagePath != null)
            Image.asset(iconImagePath, height: 24, width: 24)
          else if (icon != null)
            Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}


  /// Méthode pour construire un bouton d'option avec dégradé et icône
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
    required Color textColor,
    bool isIconImage = false,
    String? iconImagePath,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: isIconImage
            ? Image.asset(
                iconImagePath!,
                height: 24,
                width: 24,
                // Supprimer le filtre de couleur si vous souhaitez conserver les couleurs originales de l'image
              )
            : Icon(icon, color: Colors.black), // Icône en noir
        label: Text(
          label,
          style: TextStyle(
            color: textColor, // Couleur du texte spécifiée
            fontWeight: FontWeight.bold,
            fontSize: 18, // Augmentation de la taille du texte
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparent pour montrer le dégradé
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Réduction de la hauteur
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Fonctions originales sans modifications
  void _makePhoneCall(String mobile) {
    final Uri url = Uri(scheme: 'tel', path: mobile);
    launchUrl(url);
  }

  void _openWhatsApp(String mobile) {
    final Uri url = Uri.parse("https://wa.me/212${mobile.substring(1)}");
    launchUrl(url);
  }

  // Méthode pour copier le numéro de téléphone dans le presse-papiers
  void _copyToClipboard(String mobile) {
    Clipboard.setData(ClipboardData(text: mobile));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم نسخ الرقم إلى الحافظة")),
    );
  }

  // Méthode pour mettre en évidence le texte correspondant à la recherche
  RichText _highlightText(String text, String query, {bool isBold = false}) {
    if (query.isEmpty) {
      return RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }

    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();
    final matches = <TextSpan>[];

    int start = 0;
    int index = lowerCaseText.indexOf(lowerCaseQuery, start);
    while (index != -1) {
      if (index > start) {
        matches.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ));
      }
      matches.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: Colors.green,
          fontSize: 18,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ));
      start = index + query.length;
      index = lowerCaseText.indexOf(lowerCaseQuery, start);
    }

    if (start < text.length) {
      matches.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: matches),
      textAlign: TextAlign.right,
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: widget.bgColor,
    appBar: AppBar(
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      backgroundColor: widget.iconColor,
      centerTitle: true,
    ),
    body: Column(
      children: [
        const SizedBox(height: 12), // Espacement en haut
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Directionality(
            textDirection: TextDirection.rtl, // Assure l'alignement RTL pour l'entrée en arabe
            child: TextField(
              textAlign: TextAlign.right, // Alignement du texte à droite
              decoration: const InputDecoration(
                labelText: 'البحث...', // Utilisation de labelText au lieu de label widget
                labelStyle: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Espacement approprié pour le texte du label
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, // Couleur de la bordure (optionnelle)
                    width: 1.0, // Largeur explicite de la bordure
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey, // Bordure lorsque le TextField est désactivé
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Couleur de la bordure lors du focus
                    width: 2.0,
                  ),
                ),
                suffixIcon: Icon(Icons.search), // Icône de recherche
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              onChanged: _filterContacts, // Ajout de la logique de filtrage
            ),
          ),
        ),
        const SizedBox(height: 10), // Ajout d'espace entre TextField et la liste
        isLoading
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
            : filteredContacts.isEmpty
                ? const Expanded(child: Center(child: Text('Aucun contact trouvé.')))
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        final etab = contact["etab"] ?? "Établissement inconnu";
                        final nom = contact["nom"] ?? "Nom inconnu";
                        final mobile = contact["mobile"] ?? "Numéro inconnu";
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10.0),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _highlightText(etab, _searchQuery, isBold: true), // etab en gras
                                const SizedBox(height: 5),
                                _highlightText("المدير(ة): $nom", _searchQuery), // nom sans gras
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(_getCycleIconBySheet(widget.sheetName), color: widget.iconColor),
                              onPressed: () {
                                _showContactOptions(context, etab, mobile);
                              },
                            ),
                            leading: IconButton(
                              icon: const Icon(Icons.more_vert), // Trois points verticaux
                              color: widget.iconColor, // Appliquer la même couleur que l'icône principale
                              onPressed: () {
                                _showContactOptions(context, etab, mobile);
                              },
                            ),
                            onTap: () {
                              _showContactOptions(context, etab, mobile);
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ],
    ),
  );
}

}
