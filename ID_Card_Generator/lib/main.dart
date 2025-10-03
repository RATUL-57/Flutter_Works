import 'dart:io' show File;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const UserInputPage(),
    );
  }
}

// ==================== FORM PAGE ====================
class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  State<UserInputPage> createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final instNameController = TextEditingController();
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final programController = TextEditingController();
  final deptController = TextEditingController();

  // Image variables
  File? logoImage;
  File? profileImage;
  Uint8List? logoBytes;
  Uint8List? profileBytes;

  final picker = ImagePicker();

  Future<void> _pickImage(bool isLogo) async {
    if (kIsWeb) {
      // On web use file_picker
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          if (isLogo) {
            logoBytes = result.files.first.bytes;
          } else {
            profileBytes = result.files.first.bytes;
          }
        });
      }
    } else {
      // On mobile use image_picker
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          if (isLogo) {
            logoImage = File(picked.path);
          } else {
            profileImage = File(picked.path);
          }
        });
      }
    }
  }

  void _generateCard() {
    if (_formKey.currentState!.validate()) {
      if ((logoImage == null && logoBytes == null) ||
          (profileImage == null && profileBytes == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select logo and profile photo")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardWithChanger(
            institutionLogoFile: logoImage,
            institutionLogoBytes: logoBytes,
            institutionName: instNameController.text,
            profilePhotoFile: profileImage,
            profilePhotoBytes: profileBytes,
            studentId: idController.text,
            studentName: nameController.text,
            program: programController.text,
            department: deptController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Info Form"),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Institution Logo Picker
              ElevatedButton(
                onPressed: () => _pickImage(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text("Pick Institution Logo"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: instNameController,
                decoration: const InputDecoration(labelText: "Institution Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter institution name" : null,
              ),
              const SizedBox(height: 12),

              // Profile Picker
              ElevatedButton(
                onPressed: () => _pickImage(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text("Pick Profile Photo"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: idController,
                decoration: const InputDecoration(labelText: "Student ID"),
                validator: (value) =>
                    value!.isEmpty ? "Enter student ID" : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Student Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter student name" : null,
              ),
              TextFormField(
                controller: programController,
                decoration: const InputDecoration(labelText: "Program"),
                validator: (value) =>
                    value!.isEmpty ? "Enter program" : null,
              ),
              TextFormField(
                controller: deptController,
                decoration: const InputDecoration(labelText: "Department"),
                validator: (value) =>
                    value!.isEmpty ? "Enter department" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text("Generate ID Card"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== CARD WIDGET ====================
class CardWithChanger extends StatefulWidget {
  final File? institutionLogoFile;
  final Uint8List? institutionLogoBytes;
  final String institutionName;
  final File? profilePhotoFile;
  final Uint8List? profilePhotoBytes;
  final String studentId;
  final String studentName;
  final String program;
  final String department;

  const CardWithChanger({
    super.key,
    this.institutionLogoFile,
    this.institutionLogoBytes,
    required this.institutionName,
    this.profilePhotoFile,
    this.profilePhotoBytes,
    required this.studentId,
    required this.studentName,
    required this.program,
    required this.department,
  });

  @override
  State<CardWithChanger> createState() => _CardWithChangerState();
}

class _CardWithChangerState extends State<CardWithChanger> {
  final List<Color> colors = [
    Colors.white,
    const Color(0xFFFFF3E0),
    const Color(0xFFE3F2FD),
    const Color(0xFFE8F5E9),
    const Color(0xFFFCE4EC),
  ];
  int currentColorIndex = 0;

  final List<TextStyle Function()> fonts = [
    () => GoogleFonts.roboto(),
    () => GoogleFonts.lato(),
    () => GoogleFonts.poppins(),
    () => GoogleFonts.montserrat(),
    () => GoogleFonts.openSans(),
  ];
  int currentFontIndex = 0;

  void changeColor() {
    setState(() {
      currentColorIndex = Random().nextInt(colors.length);
    });
  }

  void changeFont() {
    setState(() {
      currentFontIndex = Random().nextInt(fonts.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontStyle = fonts[currentFontIndex]();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated ID Card"),
        backgroundColor: Colors.green[800],
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== The Card =====
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: colors[currentColorIndex],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DefaultTextStyle(
                  style: fontStyle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== Header with Logo & Institution Name + Profile overlap =====
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 3, 43, 0),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (widget.institutionLogoFile != null)
                                  Image.file(widget.institutionLogoFile!,
                                      height: 60)
                                else if (widget.institutionLogoBytes != null)
                                  Image.memory(widget.institutionLogoBytes!,
                                      height: 60),
                                const SizedBox(height: 8),
                                Text(
                                  widget.institutionName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: fontStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 70),
                              ],
                            ),
                          ),

                          // Profile photo
                          Positioned(
                            bottom: -50,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: widget.profilePhotoFile != null
                                      ? Image.file(
                                          widget.profilePhotoFile!,
                                          height: 100,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : widget.profilePhotoBytes != null
                                          ? Image.memory(
                                              widget.profilePhotoBytes!,
                                              height: 100,
                                              width: 90,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.person,
                                              size: 90, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),

                      // Student ID
                      _buildInfoRow("Student ID", widget.studentId,
                          Icons.vpn_key, fontStyle),

                      // Student Name
                      _buildInfoRow("Student Name", widget.studentName,
                          Icons.person, fontStyle),

                      // Program
                      _buildInlineRow("Program :", widget.program,
                          Icons.school, fontStyle),

                      // Department
                      _buildInlineRow("Department :", widget.department,
                          Icons.account_tree, fontStyle),

                      // Location (static example)
                      _buildInlineRow("Location :", "Bangladesh",
                          Icons.location_on, fontStyle),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 3, 43, 0),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          "A subsidiary organ of OIC",
                          textAlign: TextAlign.center,
                          style: fontStyle.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: changeColor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Change Color"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: changeFont,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Change Font"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, TextStyle fontStyle) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                label,
                style: fontStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            value,
            style: fontStyle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInlineRow(
      String label, String value, IconData icon, TextStyle fontStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: fontStyle.copyWith(color: Colors.grey, fontSize: 14),
          ),
          Text(
            " $value",
            style: fontStyle.copyWith(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
