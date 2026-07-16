import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // የ Supabase ዳታቤዝህን እዚህ ታስገባለህ
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const NatureHealApp());
}

class NatureHealApp extends StatelessWidget {
  const NatureHealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NatureHeal AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MainPortalScreen(),
    );
  }
}

class MainPortalScreen extends StatefulWidget {
  const MainPortalScreen({super.key});

  @override
  State<MainPortalScreen> createState() => _MainPortalScreenState();
}

class _MainPortalScreenState extends State<MainPortalScreen> {
  String selectedLanguage = 'አማርኛ';
  final TextEditingController _searchController = TextEditingController();
  
  // የካሜራ እና የምስል ተለዋዋጮች
  File? _selectedImage;
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();

  // ካሜራውን የሚከፍተው ተግባር
  Future<void> _openCameraScanner() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _isScanning = true;
        });

        // AI ምስሉን እየመረመረ መሆኑን ለማስመሰል የ3 ሰከንድ ጥበቃ (ወደፊት ከእውነተኛው AI ጋር ይገናኛል)
        await Future.delayed(const Duration(seconds: 3));

        setState(() {
          _isScanning = false;
        });

        // የ AI ምርመራ ውጤት ማሳያ
        _showAnalysisResult();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ካሜራውን መክፈት አልተቻለም!')),
      );
    }
  }

  void _showAnalysisResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            Text('የ AI ትንተና ውጤት', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌿 ተክል: ሞሪንጋ (Moringa)'),
            const SizedBox(height: 10),
            const Text('🧪 ንጥረ ነገር: ቪታሚን ሲ፣ ፕሮቲን፣ አይረን'),
            const SizedBox(height: 10),
            const Text('💪 ጥቅም: ለደም ግፊት እና ለስኳር በሽታ ይረዳል'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _selectedImage = null; });
            },
            child: const Text('ዝጋ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 30),
            const SizedBox(width: 10),
            Text(
              'NatureHeal AI',
              style: GoogleFonts.poppins(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: const Icon(Icons.language, color: Colors.black54),
                items: <String>['አማርኛ', 'English', 'Afaan Oromoo', 'Tigrinya']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() { selectedLanguage = newValue!; });
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'እንኳን ደህና መጡ!',
                style: GoogleFonts.notoSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              
              // ፎቶ ከተነሳ በኋላ የሚታየው የምስል እና አኒሜሽን ክፍል
              if (_selectedImage != null)
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _selectedImage!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isScanning)
                        Column(
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                            const SizedBox(height: 10),
                            Text(
                              'AI እፅዋቱን እየመረመረ ነው...',
                              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              else
                // ዋናው የፍለጋ ክፍል (ምስል ከሌለ የሚታይ)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ህመምዎን ወይም እፅዋቱን ይፃፉ...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.mic, color: Colors.blue),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.document_scanner_outlined, color: Color(0xFF2E7D32)),
                            onPressed: _openCameraScanner,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCameraScanner,
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('ካሜራ ክፈት', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
