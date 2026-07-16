import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      debugShowCheckedModeBanner: false,
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
  String _result = "ዕፅዋትን፣ ማዕድናትን ወይም ህመምን ይፈልጉ...";

  Future<void> _searchPlant(String value) async {
    final data = await Supabase.instance.client
        .from('plants')
        .select('scientific_name, nutrients, health_benefits')
        .ilike('scientific_name', '%$value%')
        .maybeSingle();

    setState(() {
      if (data != null) {
        _result = "ስም: ${data['scientific_name']}\n\n"
                  "ንጥረ ነገሮች: ${data['nutrients']}\n\n"
                  "ጥቅም: ${data['health_benefits']}";
      } else {
        _result = "ይቅርታ፣ መረጃው አልተገኘም። እባክዎ በትክክለኛ ስም ይፈልጉ።";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NatureHeal AI - Health')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: _searchPlant,
              decoration: const InputDecoration(
                hintText: 'በሳይንሳዊ ስም ይፈልጉ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(_result))),
          ],
        ),
      ),
    );
  }
}
