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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = "ተክሉን ይፈልጉ...";
  final TextEditingController _controller = TextEditingController();

  Future<void> _searchPlant(String value) async {
    final data = await Supabase.instance.client
        .from('plants')
        .select('*')
        .ilike('scientific_name', '%$value%')
        .maybeSingle();

    setState(() {
      if (data != null) {
        _result = "ስም: ${data['scientific_name']}\nንጥረ ነገሮች: ${data['nutrients']}";
      } else {
        _result = "ተክሉ አልተገኘም";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NatureHeal AI')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (value) => _searchPlant(value),
              decoration: const InputDecoration(
                hintText: 'ዕፅዋትን በሳይንሳዊ ስም ይፈልጉ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
