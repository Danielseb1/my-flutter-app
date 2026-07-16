import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // የ Supabase ግንኙነት
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

  // ጋለሪ ወይም ካሜራ ለመምረጥ
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF1B5E20)),
              title: const Text('ፎቶ አንሳ (Camera)'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1B5E20)),
              title: const Text('ከጋለሪ ምረጥ (Gallery)'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ፎቶ ከተመረጠ በኋላ እውነተኛውን Gemini AI የሚያነጋግረው ክፍል
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _isAnalyzing = true;
        });

        // 1. የሰጠኸኝን የ Gemini ቁልፍ እናዘጋጃለን
        const apiKey = 'AQ.Ab8RN6LB6FH4jazQkgbO_gxhT7wiJJSFlJF-mHIi2vFztL6EpA';
        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
        
        // 2. ምስሉን ወደ ዳታ እንቀይረዋለን
        final imageBytes = await _selectedImage!.readAsBytes();
        
        // 3. ለ AI የምንሰጠው ትዕዛዝ (Prompt) በመረጥከው ቋንቋ እንዲመልስ
        final promptText = 'ይህንን ምስል በጥልቀት መርምር። በምስሉ ላይ ያለው እፅዋት፣ ፍራፍሬ፣ ማዕድን ወይም የሰውነት ክፍል ከሆነ፡ 1. ስሙን፣ 2. በውስጡ ያሉትን ንጥረ ነገሮች (ቪታሚን/ፕሮቲን)፣ 3. የጤና ጥቅሙን፣ 4. የባህል ህክምና አጠቃቀሙን እና 5. ከዘመናዊ መድሃኒት ጋር ያለውን ግንኙነት በዝርዝር በ $selectedLanguage ቋንቋ ፃፍልኝ።';
        
        final prompt = TextPart(promptText);
        final imagePart = DataPart('image/jpeg', imageBytes);

        // 4. ወደ AI ልከን መልሱን እንጠብቃለን
        final response = await model.generateContent([
          Content.multi([prompt, imagePart])
        ]);

        setState(() {
          _isAnalyzing = false;
        });

        // 5. የመጣውን እውነተኛ ውጤት እናሳያለን
        _showAnalysisResult(response.text ?? 'ይቅርታ፣ ምስሉን በሚገባ መተንተን አልተቻለም።');
      }
    } catch (e) {
      setState(() { _isAnalyzing = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ከ AI ጋር መገናኘት አልተቻለም: የኢንተርኔት ግንኙነትዎን ያረጋግጡ።')),
      );
    }
  }

  // የ AI ትንተና ውጤት ማሳያ
  void _showAnalysisResult(String resultText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text('የ AI ትንተና', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            resultText,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ዝጋ', style: TextStyle(color: Color(0xFF1B5E20))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
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
                        icon: const Icon(Icons.language, color: Color(0xFF1B5E20)),
                        items: <String>['አማርኛ', 'English', 'Afaan Oromoo', 'Tigrinya']
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'የጤናዎ ባለሙያ!',
                        style: GoogleFonts.notoSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'እፅዋትን፣ ማዕድናትን ወይም ህመምዎን በመግለፅ በ AI የታገዘ ትንተና ያግኙ።',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 2, blurRadius: 15),
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
                                IconButton(icon: const Icon(Icons.mic, color: Colors.blueAccent), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.center_focus_strong, color: Color(0xFF1B5E20)), onPressed: _showImageSourceActionSheet),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      if (_selectedImage != null)
                        Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(_selectedImage!, height: 300, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_isAnalyzing)
                                Column(
                                  children: [
                                    const CircularProgressIndicator(color: Color(0xFF1B5E20)),
                                    const SizedBox(height: 15),
                                    Text('AI ምስሉን እያጠናቀረ ነው... እባክዎ ይጠብቁ', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
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
        label: const Text('ምስል አስገባ (Scan)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
