import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://mstphukumdxcsvtrelkd.supabase.co',
    anonKey: 'sb_publishable_FckQyv4DiWQGEa20E_s0bQ_PZVhe15d',
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
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
  
  File? _selectedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  // የቋንቋ ትርጉም ለ UI (አፕሊኬሽኑ ላይ ለሚታዩ ፅሁፎች)
  final Map<String, Map<String, String>> uiTexts = {
    'አማርኛ': {
      'title': 'የጤናዎ ባለሙያ!',
      'subtitle': 'እፅዋትን፣ ማዕድናትን ወይም ህመምዎን በመግለፅ በ AI የታገዘ ትንተና ያግኙ።',
      'hint': 'ህመምዎን ወይም እፅዋቱን ይፃፉ...',
      'scan_btn': 'ምስል አስገባ (Scan)',
      'camera': 'ፎቶ አንሳ (Camera)',
      'gallery': 'ከጋለሪ ምረጥ (Gallery)',
      'analyzing': 'AI መረጃውን እያጠናቀረ ነው... እባክዎ ይጠብቁ',
      'error': 'ከ AI ጋር መገናኘት አልተቻለም! ኢንተርኔትዎን ያረጋግጡ።',
    },
    'English': {
      'title': 'Your Health Expert!',
      'subtitle': 'Get AI-powered analysis by describing plants, minerals, or your symptoms.',
      'hint': 'Type your symptom or plant...',
      'scan_btn': 'Upload Image (Scan)',
      'camera': 'Take Photo (Camera)',
      'gallery': 'Choose from Gallery',
      'analyzing': 'AI is analyzing... please wait',
      'error': 'Failed to connect to AI! Check your internet.',
    },
  };

  // የ API ቁልፍህ
  final String apiKey = 'AQ.Ab8RN6LB6FH4jazQkgbO_gxhT7wiJJSFlJF-mHIi2vFztL6EpA';

  // 1. በፅሁፍ ለሚላክ ጥያቄ AI-ውን የሚያነጋግረው ክፍል
  Future<void> _submitTextQuery() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _selectedImage = null; // ምስል ካለ እናጠፋዋለን
    });

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final promptText = 'Answer in $selectedLanguage. The user is asking about a health condition, plant, or mineral: "$query". Please analyze this and provide: 1. Name/Identification, 2. Nutrients/Vitamins (if applicable), 3. Health benefits, 4. Traditional medicine use, 5. Modern medicine synergy.';
      
      final response = await model.generateContent([Content.text(promptText)]);
      _showAnalysisResult(response.text ?? 'ምንም መረጃ አልተገኘም።');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(uiTexts[selectedLanguage]!['error']!)));
    } finally {
      setState(() { _isAnalyzing = false; });
    }
  }

  // 2. በምስል (ስካን) ለሚላክ ጥያቄ AI-ውን የሚያነጋግረው ክፍል
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _isAnalyzing = true;
          _searchController.clear(); // ፅሁፉን እናጠፋዋለን
        });

        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
        final imageBytes = await _selectedImage!.readAsBytes();
        
        final promptText = 'Answer in $selectedLanguage. Analyze this image. If it is a plant, fruit, mineral, or symptom, provide: 1. Name, 2. Nutrients/Vitamins, 3. Health benefits, 4. Traditional medicine use, 5. Modern medicine synergy.';
        final response = await model.generateContent([
          Content.multi([TextPart(promptText), DataPart('image/jpeg', imageBytes)])
        ]);

        _showAnalysisResult(response.text ?? 'ምስሉን በሚገባ መተንተን አልተቻለም።');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(uiTexts[selectedLanguage]!['error']!)));
    } finally {
      setState(() { _isAnalyzing = false; });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF1B5E20)),
              title: Text(uiTexts[selectedLanguage]!['camera']!),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1B5E20)),
              title: Text(uiTexts[selectedLanguage]!['gallery']!),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisResult(String resultText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text('AI Analysis', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(resultText, style: const TextStyle(fontSize: 15, height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF1B5E20))),
          ),
        ],
      ),
    );
  }

  // የድምፅ ቅረፃ (ለጊዜው መልዕክት ብቻ የሚያሳይ)
  void _handleVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('የድምፅ ቅረፃን ለመጠቀም በአንድሮይድ ላይ Audio Permission ማስተካከል ስለሚጠይቅ በቅርቡ ይጨመራል!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textData = uiTexts[selectedLanguage]!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                title: Row(
                  children: [
                    const Icon(Icons.eco, color: Color(0xFF1B5E20), size: 32),
                    const SizedBox(width: 10),
                    Text(
                      'NatureHeal AI',
                      style: GoogleFonts.poppins(color: const Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        icon: const Icon(Icons.language, color: Color(0xFF1B5E20)),
                        items: ['አማርኛ', 'English'].map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                        )).toList(),
                        onChanged: (String? newValue) {
                          setState(() { selectedLanguage = newValue!; });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textData['title']!, style: GoogleFonts.notoSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                      const SizedBox(height: 10),
                      Text(textData['subtitle']!, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5)),
                      const SizedBox(height: 30),
                      
                      // የፍለጋ ሳጥን ከተጨማሪ የመላኪያ (Send) ቁልፍ ጋር
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 2, blurRadius: 15)],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) => _submitTextQuery(),
                          decoration: InputDecoration(
                            hintText: textData['hint']!,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.mic, color: Colors.blueAccent),
                                  onPressed: _handleVoiceInput,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send, color: Color(0xFF1B5E20)),
                                  onPressed: _submitTextQuery, // ይህ የመላኪያ (Send) ቁልፍ ነው!
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      if (_selectedImage != null)
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(_selectedImage!, height: 250, width: double.infinity, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        
                      if (_isAnalyzing)
                        Center(
                          child: Column(
                            children: [
                              const CircularProgressIndicator(color: Color(0xFF1B5E20)),
                              const SizedBox(height: 15),
                              Text(textData['analyzing']!, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImageSourceActionSheet,
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 4,
        icon: const Icon(Icons.document_scanner, color: Colors.white),
        label: Text(textData['scan_btn']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
