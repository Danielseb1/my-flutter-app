import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
        textTheme: GoogleFonts.notoSansTextTheme(Theme.of(context).textTheme),
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
  String _selectedLanguage = 'አማርኛ';
  final TextEditingController _searchController = TextEditingController();
  
  File? _selectedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  
  // የድምፅ ፓኬጆች
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  final String apiKey = 'AIzaSyAkMzSH3OaT-OdAek5JoFWXBqF5Fp6lzzQ';

  final Map<String, Map<String, String>> uiTexts = {
    'አማርኛ': {
      'title': 'የጤናዎ ባለሙያ!',
      'subtitle': 'እፅዋትን፣ ማዕድናትን፣ ቅመማቅመሞችን ወይም ህመምዎን በፅሁፍ፣ በድምፅ ወይንም በካሜራ በመግለፅ ጥልቅ ትንተና ያግኙ።',
      'hint': 'ህመምዎን ወይም እፅዋቱን ይፃፉ...',
      'analyzing': 'AI መረጃውን እያጠናቀረ ነው... እባክዎ ይጠብቁ',
      'error': 'ከ AI ጋር መገናኘት አልተቻለም! ኢንተርኔትዎን ያረጋግጡ።',
      'voice_hint': 'እየሰማሁዎት ነው... ይናገሩ!',
    },
    'English': {
      'title': 'Your Health Expert!',
      'subtitle': 'Analyze plants, minerals, spices, or symptoms using Text, Voice, or Camera for deep insights.',
      'hint': 'Type your symptom or plant...',
      'analyzing': 'AI is analyzing... please wait',
      'error': 'Connection failed! Check your internet.',
      'voice_hint': 'Listening... speak now!',
    },
  };

  @override
  void initState() {
    super.initState();
    _initSpeechAndTts();
  }

  void _initSpeechAndTts() async {
    await _speechToText.initialize();
    await _flutterTts.setLanguage("am-ET");
    await _flutterTts.setSpeechRate(0.5);
  }

  // 1. የድምፅ ማዳመጥ (Voice to Text)
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(onResult: (val) {
          setState(() {
            _searchController.text = val.recognizedWords;
          });
          if (val.finalResult) {
            setState(() => _isListening = false);
            _submitQuery();
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  // 2. ፅሁፍን ወይም የድምፅ ውጤትን ለ AI መላክ
  Future<void> _submitQuery() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _selectedImage = null;
    });

    try {
      final model = GenerativeModel(
  model: 'gemini-2.0-flash',
  apiKey: apiKey,
);
      final promptText = 'Answer precisely in $_selectedLanguage. The user is asking about: "$query". Provide: 1. Exact Name, 2. Vitamins/Proteins/Nutrients it contains, 3. Health benefits, 4. Traditional medicine usage, 5. Synergy or relation with Modern medicine.';
      
      final response = await model.generateContent([Content.text(promptText)]);
      String finalResult = response.text ?? 'ምንም መረጃ አልተገኘም።';
      
      _showAnalysisResult(finalResult);
      await _flutterTts.speak(finalResult); // በድምፅ ማሰማት (Text to Voice)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ስህተት: $e')));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  // 3. ምስል ስካን አድርጎ ለ AI መላክ
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _isAnalyzing = true;
          _searchController.clear();
        });

        final model = GenerativeModel(
  model: 'gemini-2.0-flash',
  apiKey: apiKey,
);
        final imageBytes = await _selectedImage!.readAsBytes();
        
        final promptText = 'Answer completely in $_selectedLanguage. Analyze this image (plant, fruit, spice, bark, mineral, or symptom). Provide: 1. Identification Name, 2. Vitamins/Proteins/Nutrients present, 3. Health benefits, 4. Traditional medicine application, 5. Synergy with Modern medicine.';
        
        final response = await model.generateContent([
          Content.multi([TextPart(promptText), DataPart('image/jpeg', imageBytes)])
        ]);

        String finalResult = response.text ?? 'ምስሉን በሚገባ መተንተን አልተቻለም።';
        _showAnalysisResult(finalResult);
        await _flutterTts.speak(finalResult); // በድምፅ ማሰማት
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ስህተት: $e')));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF1B5E20)),
              title: const Text('ካሜራ (Camera)'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1B5E20)),
              title: const Text('ጋለሪ (Gallery)'),
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
            Text('NatureHeal AI', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(child: Text(resultText, style: const TextStyle(fontSize: 15, height: 1.6))),
        actions: [
          TextButton(
            onPressed: () {
              _flutterTts.stop(); // ሲዘጋ ድምፁን ያቆማል
              Navigator.pop(context);
            },
            child: const Text('ዝጋ (Close)', style: TextStyle(color: Color(0xFF1B5E20))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textData = uiTexts[_selectedLanguage]!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE8F5E9), Colors.white]),
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
                    Text('NatureHeal AI', style: GoogleFonts.poppins(color: const Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 24)),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        icon: const Icon(Icons.language, color: Color(0xFF1B5E20)),
                        items: ['አማርኛ', 'English'].map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                        )).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                            _flutterTts.setLanguage(newValue == 'English' ? "en-US" : "am-ET");
                          });
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
                      
                      // ማራኪ የፍለጋ ሳጥን 
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), spreadRadius: 2, blurRadius: 15)],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) => _submitQuery(),
                          decoration: InputDecoration(
                            hintText: _isListening ? textData['voice_hint']! : textData['hint']!,
                            hintStyle: TextStyle(color: _isListening ? Colors.red : Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            prefixIcon: IconButton(
                              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : const Color(0xFF1B5E20), size: 28),
                              onPressed: _startListening,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.send, color: Colors.blueAccent), onPressed: _submitQuery),
                                IconButton(icon: const Icon(Icons.camera_alt, color: Color(0xFF1B5E20)), onPressed: _showImageSourceOptions),
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
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_selectedImage!, height: 250, width: double.infinity, fit: BoxFit.cover)),
                          ),
                        ),
                        
                      if (_isAnalyzing)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
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
    );
  }
}
