// lib/views/service_contacts_view.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dphoc/services/google_sheets_service.dart';
import 'package:dphoc/utils/contact_options.dart'; // Importer la classe utilitaire

class ServiceContactsView extends StatefulWidget {
  final String serviceName;
  final String title;
  final Color buttonBgColor;

  const ServiceContactsView({
    Key? key,
    required this.serviceName,
    required this.title,
    required this.buttonBgColor,
  }) : super(key: key);

  @override
  _ServiceContactsViewState createState() => _ServiceContactsViewState();
}

class _ServiceContactsViewState extends State<ServiceContactsView> {
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;
  late GoogleSheetsService _sheetsService;

  @override
  void initState() {
    super.initState();
    _sheetsService = GoogleSheetsService();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final data = await _sheetsService.loadData('services');
      setState(() {
        contacts = data
            .where((contact) => contact['service'] == widget.serviceName)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        contacts = [];
        isLoading = false;
      });
      log("Erreur lors du chargement des contacts : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Augmentez légèrement la taille du texte pour une meilleure lisibilité
    final double titleSize = screenWidth > 500 ? 20.0 : 17.0;
    final double subtitleSize = screenWidth > 500 ? 16.0 : 15.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.buttonBgColor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
              ? const Center(child: Text('Aucun contact trouvé.'))
              : Column(
                  children: [
                    // Add spacing between AppBar and content
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          final name = contact['Nom'] ?? 'غير متوفر';
                          final mobile = contact['mobile'] ?? 'غير متوفر';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                vertical: 3.0, horizontal: 8.0), // Réduisez les marges
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0), // Réduisez les paddings
                              leading: IconButton(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.grey, size: 24.0),
                                onPressed: () {
                                  ContactOptions.show(context, name, mobile);
                                },
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontSize: titleSize, // Taille de police augmentée
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              subtitle: Text(
                                mobile,
                                style: TextStyle(
                                  fontSize: subtitleSize, // Taille de police augmentée
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.right,
                              ),
                              trailing: Icon(
                                Icons.quick_contacts_mail,
                                color: widget.buttonBgColor, // Mise à jour de la couleur
                                size: 28.0,
                              ),
                              onTap: () {
                                ContactOptions.show(context, name, mobile);
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
