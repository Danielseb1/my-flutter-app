import 'package:flutter/material.dart';

void main() {
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
  String _result = "ፍለጋ ይጀምሩ...";
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
        _result = "ይህ ተክል አልተገኘም";
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
          // በ Column children ውስጥ ይህንን ብቻ ተጠቀም
children: [
  // 1. የፍለጋ ሳጥን
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
  
  // 2. ውጤት ማሳያ
  Text(
    _result, 
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  
  const SizedBox(height: 20),
  // ... የተቀረው የ Recent Scans ኮድህ ከዚህ በታች ይቀጥላል

      ),
    );
  }
}
            const Text(
              'የቅርብ ጊዜ ፍለጋዎች (Recent Scans)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.eco, color: Colors.green),
                      ),
                      title: const Text('ሞሪንጋ (Moringa)', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('ቪታሚን ኤ፣ ካልሲየም...'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.lightGreenAccent,
                        child: Icon(Icons.grass, color: Colors.green),
                      ),
                      title: const Text('የሬት እፅዋት (Aloe Vera)', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('ለቆዳ ጤንነት፣ ቪታሚን ኢ...'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// አዲሱ የስካነር (ካሜራ) ገጽ
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isScanning = false;

  void startScan() {
    setState(() {
      isScanning = true;
    });
    
    // ካሜራው ስካን እያደረገ እንደሆነ ለማስመሰል 3 ሰከንድ ይጠብቃል
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isScanning = false;
      });
      
      // ስካን አድርጎ ሲጨርስ የጤና መረጃውን (Result) ያመጣል
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('ውጤት ተገኝቷል!'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ተክል: ሞሪንጋ (Moringa)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text('ይህ ተክል ከፍተኛ የቪታሚን ኤ፣ ካልሲየም፣ እና ፕሮቲን ይዘት አለው። በሽታ የመከላከል አቅምን ይጨምራል።'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ቦክሱን ይዘጋዋል
                Navigator.pop(context); // ወደ ዋናው ገጽ ይመለሳል
              },
              child: const Text('ጨርስ', style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // የካሜራ ገጽ ስለሆነ ጥቁር ጀርባ
      appBar: AppBar(
        title: const Text('እፅዋትን ስካን ያድርጉ'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // የካሜራ ፎረም (Camera Frame)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isScanning 
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : const Icon(Icons.camera_alt, size: 80, color: Colors.white54),
            ),
            const SizedBox(height: 40),
            
            isScanning
                ? const Text('ተክሉን በመለየት ላይ...', style: TextStyle(color: Colors.white, fontSize: 18))
                : ElevatedButton.icon(
                    onPressed: startScan,
                    icon: const Icon(Icons.camera),
                    label: const Text('ፎቶ አንሳ (Capture)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // በ Supabase dashboard ላይ የምታገኘውን የፕሮጀክት URL እና ANON KEY እዚህ አስገባ
// በ main.dart ፋይልህ ውስጥ ይህንን አስተካክል
  await Supabase.initialize(
    url: 'https://mstphukumdxcsvtrelkd.supabase.co',
    anonKey: 'sb_publishable_FckQyv4DiWQGEa20E_s0bQ_PZVhe15d',
  );

// በ _HomePageState ክፍል ውስጥ ያለው build ሜተድ
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('NatureHeal AI')),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. የፍለጋ ሳጥኑ (TextField)
          TextField(
            controller: _controller,
            onSubmitted: (value) => _searchPlant(value), // የፍለጋ ተግባሩን ያነሳሳል
            decoration: const InputDecoration(
              hintText: 'ዕፅዋትን በሳይንሳዊ ስም ይፈልጉ...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // 2. የውጤት ማሳያው (Text Widget)
          Text(
            _result,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 20),
          // ከዚህ በታች ሌሎች ቁልፎችህን ወይም Recent Scans ሊስትህን ማስቀመጥ ትችላለህ
        ],
      ),
    ),
  );
}

