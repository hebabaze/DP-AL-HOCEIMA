// lib/views/inspector_details_view.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dphoc/services/google_sheets_service.dart';
import 'package:dphoc/utils/contact_options.dart'; // Importer la classe utilitaire

class InspectorDetailsView extends StatefulWidget {
  final String cycleName; // Le nom du cycle passé depuis la vue parente

  const InspectorDetailsView({super.key, required this.cycleName});

  @override
  _InspectorDetailsViewState createState() => _InspectorDetailsViewState();
}

class _InspectorDetailsViewState extends State<InspectorDetailsView> {
  List<Map<String, dynamic>> inspectors = [];
  List<Map<String, dynamic>> filteredInspectors = [];
  bool isLoading = true;

  late GoogleSheetsService _sheetsService;

  @override
  void initState() {
    super.initState();
    _sheetsService = GoogleSheetsService();
    _loadInspectors();
  }

  Future<void> _loadInspectors() async {
    try {
      final data = await _sheetsService.loadData('inspectors');
      setState(() {
        inspectors = data.where((inspector) => inspector['cycle'] == widget.cycleName).toList();
        filteredInspectors = List.from(inspectors);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        inspectors = [];
        filteredInspectors = [];
        isLoading = false;
      });
      log("Error loading inspectors: $e");
    }
  }

  void _filterInspectors(String query) {
    setState(() {
      filteredInspectors = inspectors.where((inspector) {
        final name = inspector["Nom"]?.toString().toLowerCase() ?? "";
        final mobile = inspector["mobile"]?.toString() ?? "";

        return name.contains(query.toLowerCase()) || mobile.contains(query);
      }).toList();
    });
  }

  // Mapping des noms de cycles aux labels en arabe pour AppBar et leurs couleurs respectives
  // Réintégration de 'primaire' si nécessaire
  final Map<String, String> cycleLabels = {
    'primaire': 'مفتشو السلك الابتدائي',
    'secondaire': 'مفتشو السلك التأهيلي',
    'finance': 'مفتشو الشؤون المالية',
    'planification': 'مفتشو التخطيط التربوي',
    'orientation': 'مفتشو التوجيه التربوي',
    'conseiller': 'مستشارو التوجيه التربوي',
  };

  final Map<String, Color> cycleButtonColors = {
    'primaire': Colors.black45,
    'secondaire': Colors.deepPurpleAccent,
    'finance': Colors.deepOrange,
    'planification': Colors.teal,
    'orientation': Colors.green,
    'conseiller': Colors.blue,
  };

  // Méthode pour créer une carte avec un ListTile pour chaque inspecteur
  Widget _createInspectorCard(BuildContext context, String name, String mobile, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(
            // Si la police est définie globalement dans main.dart, vous pouvez omettre fontFamily ici
            // fontFamily: '4_3D', // Utilisation de la police personnalisée
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.right, // Alignement à droite pour RTL
        ),
        subtitle: Text(
          mobile,
          style: TextStyle(
            // fontFamily: '4_3D', // Si la police est définie globalement, ce n'est pas nécessaire
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.right, // Alignement à droite pour RTL
        ),
        trailing: const Icon(Icons.more_vert),
        onTap: () {
          ContactOptions.show(context, name, mobile);
        },
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double textSize = screenWidth > 500 ? 24.0 : 18.0;

  return Directionality(
    textDirection: TextDirection.rtl, // Assurer la direction RTL pour l'ensemble de la vue
    child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Directionality(
          textDirection: TextDirection.ltr, // Forcer l'AppBar en LTR pour placer la flèche de retour à gauche
          child: AppBar(
            title: Text(
              cycleLabels[widget.cycleName] ?? 'Inspecteurs', // Titre par défaut si cycleName non trouvé
              style: const TextStyle(
                fontFamily: '4_3D', // Utilisation de la police personnalisée
              ),
            ),
            backgroundColor: Colors.blue, // Utilisation de backgroundColor à la place de primary
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12), // Espacement en haut
          // Afficher le champ de recherche uniquement si le nombre d'inspecteurs est >= 6
          if (inspectors.length >= 6)
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
                  onChanged: _filterInspectors, // Ajout de la logique de filtrage
                ),
              ),
            ),
          const SizedBox(height: 10), // Ajout d'espace entre TextField et la liste
          isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: filteredInspectors.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun inspecteur trouvé.",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredInspectors.length,
                          itemBuilder: (context, index) {
                            final inspector = filteredInspectors[index];
                            final name = inspector["Nom"] ?? "Nom inconnu";
                            final mobile = inspector["mobile"] ?? "Numéro inconnu";
                            final color = cycleButtonColors[widget.cycleName] ?? Colors.blue;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0), // Espace entre les cartes
                              child: _createInspectorCard(context, name, mobile, color),
                            );
                          },
                        ),
                ),
        ],
      ),
    ),
  );
}

}
