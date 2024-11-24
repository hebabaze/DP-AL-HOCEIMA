// lib/views/school_contacts_view.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dphoc/services/google_sheets_service.dart'; // Import GoogleSheetsService
import 'package:dphoc/utils/contact_options.dart'; // Import ContactOptions

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
                            icon: Icon(
                              _getCycleIconBySheet(widget.sheetName),
                              color: widget.iconColor,
                            ),
                            onPressed: () {
                              ContactOptions.show(context, etab, mobile); // Utilisation de ContactOptions
                            },
                          ),
                          onTap: () {
                            ContactOptions.show(context, etab, mobile); // Utilisation de ContactOptions
                          },),);},), ),],),);}}
