import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lockergo/custom_bottom_navigation_bar.dart';
import 'package:lockergo/screens/lockers/locker.dart';
import 'package:lockergo/screens/theme_provider.dart';
import 'package:provider/provider.dart';

class SectionSelectionScreen extends StatefulWidget {
  final String facultyName;
  final String floorNumber;
  final int floorId;

  const SectionSelectionScreen({
    super.key,
    required this.facultyName,
    required this.floorNumber,
    required this.floorId,
  });

  @override
  State<SectionSelectionScreen> createState() => _SectionSelectionScreenState();
}

class _SectionSelectionScreenState extends State<SectionSelectionScreen> {
  List<dynamic> sections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  Future<void> fetchSections() async {
    try {
      final url = Uri.parse(
          'http://pagueya-001-site3.mtempurl.com/api/secciones/${widget.floorId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sections = data; 
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sections');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching sections: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final themeProvider = Provider.of<ThemeProvider>(context); // Access the theme provider

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/header.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_name_black.png',
          height: screenHeight * 0.04, // Dynamically adjust logo size
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10), // Dynamic padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                ' ${widget.floorNumber} de la facultad de ${widget.facultyName}',
                style: TextStyle(
                  fontSize: screenHeight * 0.03, // Dynamically adjust font size
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // White for night mode
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            // Row with Text and Tooltip icon next to it
            const Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content
              children: [
                Text(
                  'Selecciona la sección',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 8), // Small space between text and icon
                Tooltip(
                  message: "Cada piso está organizado en secciones para facilitar tu elección, cada sección incluye 16 lockers en el orden que está viendo abajo.",
                  child: Icon(Icons.info, color: Colors.blue, size: 25), // Info icon
                ),
              ],
            ),

            const SizedBox(height: 20),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: sections.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay secciones disponibles.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: sections.length,
                            itemBuilder: (context, index) {
                              final section = sections[index];
                              return SectionTile(
                                facultyName: widget.facultyName,
                                floorNumber: widget.floorNumber,
                                sectionName: section['section_name'],
                                sectionId: section['id'], // Pass sectionId from API
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class SectionTile extends StatelessWidget {
  final String facultyName;
  final String floorNumber;
  final String sectionName;
  final int sectionId; // Agregado para pasar el ID de la sección

  const SectionTile({
    super.key,
    required this.facultyName,
    required this.floorNumber,
    required this.sectionName,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the theme provider

    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 8), // Dynamic padding
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: themeProvider.isDarkMode ? Color(0xFF9de9ff) : Color(0xFF0a4c86), // Blue for night mode
            width: 2.0,
          ),
        ),
        color: themeProvider.isDarkMode ? Color(0xFF0a4c86) : Colors.white, // Background color for night mode
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LockerSelectionScreen(
                  facultyName: facultyName,
                  floorNumber: floorNumber,
                  section: sectionName,
                  sectionId: sectionId, // Pasar el sectionId requerido
                ),
              ),
            );
          },
          title: Center(
            child: Text(
              sectionName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Color(0xFF9de9ff) : Color(0xFF0a4c86), // Blue for night mode
              ),
            ),
          ),
        ),
      ),
    );
  }
}
