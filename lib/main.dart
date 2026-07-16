
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
        title: const Text(
          'NatureHeal AI', 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
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
                  // ወደፊት ወደ ካሜራ ስካነሩ ገጽ የሚወስደው ኮድ እዚህ ይገባል
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ካሜራ በመክፈት ላይ...')),
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
            
            // ከዚህ በፊት ስካን የተደረጉ እፅዋት ዝርዝር ማሳያ (ለናሙና)
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
