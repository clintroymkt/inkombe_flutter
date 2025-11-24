import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_record.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';
import 'dart:io';

class CowProfilePage extends StatefulWidget {
  final String docId;
  const CowProfilePage({super.key, required this.docId});

  @override
  State<CowProfilePage> createState() => _CowProfilePageState();
}

class _CowProfilePageState extends State<CowProfilePage> {
  late Future<CattleRecord?> _cowDataFuture;

  @override
  void initState() {
    super.initState();
    _cowDataFuture = CattleSyncService.getSingleCow(widget.docId);
  }

  Widget _buildCowImage(CattleRecord data) {
    // Priority 1: Use local image file if available
    if (data.localImagePaths != null && data.localImagePaths!.isNotEmpty) {
      final file = File(data.localImagePaths![0]);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 289,
          errorBuilder: (context, error, stackTrace) => _buildNetworkImage(data),
        );
      }
    }

    // Priority 2: Use network image from Firebase Storage
    return _buildNetworkImage(data);
  }

  Widget _buildNetworkImage(CattleRecord data) {
    if (data.imageUrls != null && data.imageUrls!.isNotEmpty) {
      return Image.network(
        data.imageUrls![0],
        fit: BoxFit.cover,
        width: double.infinity,
        height: 289,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 289,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 289,
      color: Colors.grey[300],
      child: const Icon(
        Icons.pets,
        color: Colors.grey,
        size: 80,
      ),
    );
  }

  Widget _buildInfoButton(String text, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: isActive ? const Color(0x333E9249) : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF064151),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF064151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(CattleRecord data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: data.isSynced ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: data.isSynced ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.isSynced ? Icons.cloud_done : Icons.cloud_off,
            color: data.isSynced ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            data.isSynced ? 'Synced' : 'Local Only',
            style: TextStyle(
              color: data.isSynced ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    setState(() {
      _cowDataFuture = CattleSyncService.getSingleCow(widget.docId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<CattleRecord?>(
          future: _cowDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading cow data',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Cow not found',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cow Image - using same logic as ListCard
                      _buildCowImage(data),

                      // App Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          actions: [
                            _buildSyncStatus(data),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: _refreshData,
                            ),
                          ],
                        ),
                      ),

                      // Info Buttons
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 20,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color(0xFF064151),
                            ),
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildInfoButton("Info", true),
                                _buildInfoButton("Edit", false),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Content Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cow Name
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data.name.isNotEmpty ? data.name : 'Unnamed Cow',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF064151),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Breed and Age
                        Text(
                          '${data.breed.isNotEmpty ? data.breed : 'Unknown breed'} • ${data.age.isNotEmpty ? data.age : 'Unknown age'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Cow Details
                        const Text(
                          "Cow Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF064151),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow("Breed:", data.breed),
                        _buildInfoRow("Age:", data.age),
                        _buildInfoRow("Sex:", data.sex),
                        _buildInfoRow("Height:", "${data.height} m"),
                        _buildInfoRow("Weight:", "${data.weight} kg"),
                        _buildInfoRow("Health Status:", data.diseasesAilments),
                        _buildInfoRow("Date Added:", data.date),

                        const SizedBox(height: 24),

                        // Embeddings Info
                        if (data.faceEmbeddings.isNotEmpty || data.noseEmbeddings.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Biometric Data",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF064151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Face embeddings: ${data.faceEmbeddings.length} | Nose embeddings: ${data.noseEmbeddings.length}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Location History Section
                        const Text(
                          "Location History",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF064151),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0x333E9249),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  image: const DecorationImage(
                                    image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Location tracking data will appear here. Recent movements and GPS history can be viewed in this section.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF064151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}