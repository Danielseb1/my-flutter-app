import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // የ Supabase ግንኙነት - ፕሮፌሽናል አወቃቀር
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
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
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
  String _result = "ጤናዎን ለማሻሻል እፅዋትን ይፈልጉ...";

  // ለወደፊቱ ለሁሉም ንጥረ ነገሮች (ቪታሚን፣ ፕሮቲን) ተለዋዋጭ ፍለጋ
  Future<void> _searchPlant(String value) async {
    final response = await Supabase.instance.client
        .from('plants')
        .select('scientific_name, nutrients, health_benefits') // የተጨመሩ ንጥረ ነገሮች
        .ilike('scientific_name', '%$value%')
        .maybeSingle();

    setState(() {
      if (response != null) {
        _result = "ስም: ${response['scientific_name']}\n\nንጥረ ነገሮች: ${response['nutrients']}\n\nጥቅም: ${response['health_benefits']}";
      } else {
        _result = "ይቅርታ፣ መረጃው አልተገኘም ወይም ሌላ ስም ይሞክሩ።";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NatureHeal AI - የጤና ማዕከል')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: _searchPlant,
              decoration: const InputDecoration(
                hintText: 'ዕፅዋትን፣ ፍራፍሬዎችን ወይም ማዕድናትን ይፈልጉ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
