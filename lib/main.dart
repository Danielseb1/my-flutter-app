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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('NatureHeal AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'እንኳን ደህና መጡ!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              'እፅዋትን፣ ዛፎችን እና ማዕድናትን ስካን በማድረግ የጤና ጥቅሞቻቸውን፣ ቪታሚኖችን እና ማዕድናቶቻቸውን ያግኙ።',
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 40),
            
            // ዋናው የስካን ማድረጊያ ቁልፍ
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // ተጠቃሚው ሲጫን ወደ ስካነር (ካሜራ) ገጽ ይወስደዋል
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScannerPage()),
                  );
                },
                icon: const Icon(Icons.document_scanner, size: 28),
                label: const Text('አዲስ ስካን ጀምር (Scan)', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
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
          ],
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
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', 
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const NatureHealApp());
}

// ... የተቀረው የ NatureHealApp ኮድ እንደነበረ ይቀጥላል ...
// በ HomePage ውስጥ ያለው የ Body ክፍል
body: Padding(
  padding: const EdgeInsets.all(20.0),
  child: Column(
    children: [
      // የጥያቄ ሳጥን (ለጽሁፍ)
      TextField(
        decoration: InputDecoration(
          hintText: 'ህመምዎን ወይም የሚፈልጉትን ተክል ይፃፉ...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 20),
      
      // የካሜራ እና የድምፅ ቁልፎች
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () { /* ወደ ካሜራ ይወስዳል */ },
            icon: const Icon(Icons.camera_alt),
            label: const Text('ፎቶ ስካን'),
          ),
          ElevatedButton.icon(
            onPressed: () { /* የድምፅ ማዘዣ ይከፍታል */ },
            icon: const Icon(Icons.mic),
            label: const Text('በድምፅ ይጠይቁ'),
          ),
        ],
      ),
    ],
  ),
),
// ከ Supabase ዳታ ለማምጣት የሚረዳ ተግባር
Future<List<Map<String, dynamic>>> fetchPlantData(String plantName) async {
  final response = await Supabase.instance.client
      .from('plants') // የሰንጠረዡ ስም
      .select('*')
      .ilike('scientific_name', '%$plantName%'); // መፈለጊያ
      
  return response;
}

