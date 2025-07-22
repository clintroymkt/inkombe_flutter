import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/database_service.dart';

class CowProfilePage extends StatefulWidget {
  final String docId;
  const CowProfilePage({super.key, required this.docId});

  @override
  State<CowProfilePage> createState() => _CowProfilePageState();
}

class _CowProfilePageState extends State<CowProfilePage> {
  late Future<Map<String, dynamic>> _cowDataFuture;
  String cowImage = "null";

  @override
  void initState() {
    super.initState();
    _cowDataFuture = DatabaseService().getSingleCow(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _cowDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data!;
            cowImage = data['image'] ?? 'null';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Stack(
                clipBehavior: Clip.none,
                children: [
                Container(
                height: 289,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(cowImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 220,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoButton("Info", true),
                            _buildInfoButton("Edit", false),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                top: 289 - 30,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    Text(
                    data['name'].toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildInfoRow("Breed name:", data['breed'].toString()),
                  _buildInfoRow("Age:", data['age'].toString()),
                  _buildInfoRow("Sex:", data['sex'].toString()),
                  _buildInfoRow("Height(m):", data['height(m)'].toString()),
                  _buildInfoRow("Weight(kg):", data['weight(kg)'].toString()),
                  _buildInfoRow("Diet:", data['diet']?.toString() ?? "No data"),
                  _buildInfoRow("Known Diseases:", data['known_diseases']?.toString() ?? "No Data"),
                  const SizedBox(height: 16),
                  const Text(
                    "Location History",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: const Color(0x4DD98F48),

                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 117,
                          height: 108,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            image: const DecorationImage(
                              image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text("Location data will appear here"),
                        ),
                      ],
                    ),

                  ),
                          const SizedBox(height: 40),
                  ],
                  ),
                ),
              ),
            ),
            ],
            ),
            ],
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoButton(String text, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: isActive ? const Color(0xFFD98E47) : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      width: 100,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        "$label $value",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}