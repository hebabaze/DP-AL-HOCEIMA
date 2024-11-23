// view/direction_overview_view.dart
import 'package:flutter/material.dart';
import 'package:dphoc/views/service_contacts_view.dart';
import 'package:dphoc/views/director_view.dart';

class DirectionOverviewView extends StatelessWidget {
  const DirectionOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Map entre les noms des boutons et les codes des services
    final Map<String, String> serviceCodeNames = {
      "مكتب الضبط": "ordrebureau",
      "الكتابة الخاصة": "secretaire",
      "الشؤون التربوية": "dae",
      "الموارد البشرية": "grh",
      "البناءات والتجهيز والمتلكات": "construction",
      "الشؤون القانونية والتواصل": "communication",
      "الشؤون الإدارية والمالية": "finance",
      "المركز الإقليمي للإمتحانات": "exam",
      "التخطيط والخريطة المدرسية": "planification",
      "تأطير المؤسسات والتوجيه": "encadrement",
      "المركز الإقليمي لمنظومة الإعلام": "information",
    };

    // Code du service pour le directeur
    //const String directorServiceCode = "directeur";

    // Largeur du bouton du directeur provincial
    final double directorButtonWidth = screenWidth > 500 ? 380.0 : 320.0;

    // Largeur des autres boutons (augmentée)
    final double buttonWidth = screenWidth > 500 ? 400.0 : 340.0;

    final double buttonHeight =
        screenWidth > 500 ? 70.0 : 60.0; // Hauteur des boutons

    // Couleurs des boutons
    const directorButtonColor = Colors.green;
    const subButtonColor1 = Colors.green;
    const subButtonColor2 = Colors.green;
    const otherButtonColors = [
      Colors.cyan,
      Colors.purple,
      Colors.lime,
      Colors.pink,
      Colors.indigo,
      Colors.teal,
      Colors.yellow,
    ];

    // Noms des services pour les autres boutons
    final otherButtonNames = [
      "البناءات والتجهيز والمتلكات",
      "الشؤون القانونية والتواصل",
      "الشؤون الإدارية والمالية",
      "المركز الإقليمي للإمتحانات",
      "التخطيط والخريطة المدرسية",
      "تأطير المؤسسات والتوجيه",
      "المركز الإقليمي لمنظومة الإعلام"
    ];

    // Noms et couleurs des quatre boutons
    final fourButtonNames = [
      "مكتب الضبط",
      "الكتابة الخاصة",
      "الشؤون التربوية",
      "الموارد البشرية",
    ];

    final fourButtonColors = [
      const Color.fromARGB(255, 126, 185, 129),
      const Color.fromARGB(255, 126, 185, 129),
      Colors.red,
      Colors.orange,
    ];

    // Espacement entre les boutons
    const double buttonSpacing = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("مصالح المديرية", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: true, // Assure l'affichage du bouton de retour
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // Applique la direction RTL uniquement au corps
        child: SingleChildScrollView(
          child: Center( // Centre le contenu horizontalement
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Bouton du directeur provincial : "المدير الإقليمي"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DirectorView(), // Nouvelle vue pour le directeur
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: directorButtonColor,
                      minimumSize: Size(directorButtonWidth, buttonHeight),
                      maximumSize: Size(directorButtonWidth, buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "المدير الإقليمي",
                        style: TextStyle(color: Colors.white, fontSize: 22.0, fontFamily: "4_3D"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Séparateur avec la même largeur que les autres boutons
                  SizedBox(
                    width: buttonWidth,
                    child: const Divider(color: Colors.black, thickness: 2),
                  ),
                  const SizedBox(height: 8),

                  // GridView pour aligner les quatre boutons avec taille augmentée
                  SizedBox(
                    width: buttonWidth, // Définit la largeur totale de la grille
                    child: GridView.builder(
                      shrinkWrap: true, // Permet à GridView de prendre seulement l'espace nécessaire
                      physics: const NeverScrollableScrollPhysics(), // Désactive le défilement
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Nombre de colonnes
                        crossAxisSpacing: buttonSpacing, // Espacement horizontal entre les boutons
                        mainAxisSpacing: buttonSpacing, // Espacement vertical entre les boutons
                        childAspectRatio: ((buttonWidth - buttonSpacing) / 2) / buttonHeight, // Ratio pour uniformiser la taille des boutons
                      ),
                      itemCount: fourButtonNames.length,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          onPressed: () {
                            String serviceName = serviceCodeNames[fourButtonNames[index]]!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceContactsView(
                                  serviceName: serviceName,
                                  title: fourButtonNames[index],
                                  buttonBgColor: fourButtonColors[index],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fourButtonColors[index],
                            minimumSize: Size((buttonWidth - buttonSpacing) / 2, buttonHeight),
                            maximumSize: Size((buttonWidth - buttonSpacing) / 2, buttonHeight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              fourButtonNames[index],
                              style: const TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: "4_3D"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Autres boutons : affichés un par ligne avec largeur augmentée
                  for (int i = 0; i < otherButtonNames.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          String serviceName = serviceCodeNames[otherButtonNames[i]]!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceContactsView(
                                serviceName: serviceName,
                                title: otherButtonNames[i],
                                buttonBgColor: otherButtonColors[i],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: otherButtonColors[i],
                          minimumSize: Size(buttonWidth, buttonHeight),
                          maximumSize: Size(buttonWidth, buttonHeight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            otherButtonNames[i],
                            style: const TextStyle(color: Colors.white, fontSize: 22.0, fontFamily: "4_3D"),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
