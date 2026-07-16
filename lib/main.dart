import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'NatureHeal AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = "የሚፈልጉትን እፅዋት፣ ፍራፍሬ፣ ማዕድን ወይም ህመም ያስገቡ...";
  bool _isLoading = false;

  Future<void> _searchData(String value) async {
    setState(() { _isLoading = true; });
    
    try {
      // ይህ ዳታቤዝህን ለሰፊ መረጃ ይጠይቃል
      final data = await Supabase.instance.client
          .from('plants')
          .select('scientific_name, nutrients, health_benefits, traditional_use, modern_medicine_synergy')
          .ilike('scientific_name', '%$value%')
          .maybeSingle();

      setState(() {
        if (data != null) {
          _result = "🌿 ስም: ${data['scientific_name']}\n\n"
                    "🧪 ንጥረ ነገሮች (ቪታሚን/ፕሮቲን): ${data['nutrients'] ?? 'መረጃ የለም'}\n\n"
                    "💪 የጤና ጥቅም: ${data['health_benefits'] ?? 'መረጃ የለም'}\n\n"
                    "🌱 የባህል ህክምና: ${data['traditional_use'] ?? 'መረጃ የለም'}\n\n"
                    "💊 ከዘመናዊ መድሃኒት ጋር: ${data['modern_medicine_synergy'] ?? 'መረጃ የለም'}";
        } else {
          _result = "መረጃው አልተገኘም። እባክዎ በትክክለኛ ስም ይፈልጉ።";
        }
      });
    } catch (e) {
      setState(() {
        _result = "የግንኙነት ችግር ተፈጥሯል: እባክዎ ትንሽ ቆይተው ይሞክሩ።";
      });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NatureHeal AI - Health Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'ቋንቋ ይቀይሩ',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('የቋንቋ ምርጫ በቅርቡ ይታከላል...')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // የፍለጋ ቦታ ከጽሁፍ፣ ድምፅ እና ካሜራ አማራጭ ጋር
            TextField(
              controller: _controller,
              onSubmitted: _searchData,
              decoration: InputDecoration(
                hintText: 'በፅሁፍ ይፈልጉ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('የድምፅ ፍለጋ በቅርቡ ይከፈታል...')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('የካሜራ ቅኝት በቅርቡ ይከፈታል...')),
                        );
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // የፍለጋ ውጤት ማሳያ
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
