import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)), // ፕሮፌሽናል አረንጓዴ ቀለም
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

  void _openCameraScanner() {
    // ካሜራ ከፍቶ እፅዋቱን የሚያውቅበት AI እዚህ ወደፊት ይገባል
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('የካሜራ እና AI ማወቂያ በቅርቡ ይገናኛል...')),
    );
  }

  void _startVoiceSearch() {
    // የድምፅ ፍለጋ እዚህ ይገባል
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('የድምፅ ትንተና በቅርቡ ይጀመራል...')),
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
          // የቋንቋ መምረጫ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: const Icon(Icons.language, color: Colors.black54),
                items: <String>['አማርኛ', 'English', 'Afaan Oromoo', 'Tigrinya']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLanguage = newValue!;
                  });
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
              const SizedBox(height: 10),
              Text(
                'እፅዋትን፣ ማዕድናትን ወይም ህመምዎን በመግለፅ ባህላዊ እና ዘመናዊ መፍትሄዎችን ያግኙ።',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              
              // ዋናው የፍለጋ እና ካሜራ ክፍል
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
                          onPressed: _startVoiceSearch,
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
              
              const SizedBox(height: 40),
              Text(
                'ዋና ዋና አገልግሎቶች',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              
              // አገልግሎቶች
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureCard(Icons.local_florist, 'እፅዋት ማወቂያ', Colors.green),
                  _buildFeatureCard(Icons.science, 'ንጥረነገር ትንተና', Colors.orange),
                  _buildFeatureCard(Icons.medical_services, 'የህክምና ምክር', Colors.blue),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCameraScanner,
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('ስካን አድርግ', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
