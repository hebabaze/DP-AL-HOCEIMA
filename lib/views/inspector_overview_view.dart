// lib/views/inspector_overview_view.dart

import 'package:flutter/material.dart';
import 'package:dphoc/views/inspector_details_view.dart'; // Import InspectorDetailsView
class InspectorOverview extends StatelessWidget {
  const InspectorOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double textSize = screenWidth > 500 ? 24.0 : 18.0;

    // Button colors for each category
    const inspectorButtonColors = [
      Colors.black45, // مفتشي السلك الابتدائي
      Colors.deepPurpleAccent, // مفتشي السلك التأهيلي
      Colors.deepOrange, // مفتشي الشؤون المالية
      Colors.teal, // مفتشي التخطيط التربوي
      Colors.green, // مفتشي التوجيه التربوي
      Colors.blue, // أطر التوجيه التربوي
    ];

    // Mapping cycle names to Arabic labels
    const CYCLES = [
      {'name': 'primaire', 'label': 'مفتشو السلك الابتدائي'},
      {'name': 'secondaire', 'label': 'مفتشو السلك التأهيلي'},
      {'name': 'finance', 'label': 'مفتشو الشؤون المالية'},
      {'name': 'planification', 'label': 'مفتشو التخطيط التربوي'},
      {'name': 'orientation', 'label': 'مفتشو التوجيه التربوي'},
      {'name': 'conseiller', 'label': 'مستشارو التوجيه التربوي'},
    ];

    // Définir la largeur des boutons en fonction de la taille de l'écran
    final double buttonWidth = screenWidth > 500 ? 400.0 : screenWidth * 0.9;
    const double buttonHeight = 60.0; // Hauteur fixe pour les boutons
    const double buttonSpacing = 12.0; // Espacement entre les boutons

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "المفتشون وأطر التوجيه",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // Pour prendre en charge les langues RTL
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0), // Espacement vertical autour du contenu
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Espacement initial
                  const SizedBox(height: 16.0),
                  // Créer un bouton pour chaque cycle avec son label
                  ...CYCLES.map((cycle) {
                    int index = CYCLES.indexOf(cycle);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: buttonSpacing),
                      child: _createCycleButton(
                        context,
                        cycle['name']!, // Le nom du cycle, passé à la vue des détails
                        cycle['label']!, // Le label en arabe pour le cycle
                        inspectorButtonColors[index], // Couleur pour le bouton
                        textSize,
                        buttonWidth,
                        buttonHeight,
                      ),
                    );
                  }).toList(),
                  // Espacement final
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Créer les boutons pour chaque cycle
  Widget _createCycleButton(
    BuildContext context,
    String cycleName,
    String label,
    Color color,
    double textSize,
    double buttonWidth,
    double buttonHeight,
  ) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InspectorDetailsView(cycleName: cycleName), // Naviguer vers les détails de l'inspecteur
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label, // Utiliser le label en arabe pour le cycle
            style: TextStyle(
              color: Colors.white,
              fontSize: textSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
