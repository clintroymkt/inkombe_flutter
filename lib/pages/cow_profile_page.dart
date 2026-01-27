import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_record.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';
import 'package:inkombe_flutter/services/cattle_repository.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import '../utils/Utilities.dart';

class CowProfilePage extends StatefulWidget {
  final String docId;
  const CowProfilePage({super.key, required this.docId});

  @override
  State<CowProfilePage> createState() => _CowProfilePageState();
}

class _CowProfilePageState extends State<CowProfilePage> {
  late Future<CattleRecord?> _cowDataFuture;
  bool _isEditing = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Edit form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _sexController;
  late TextEditingController _healthController;

  @override
  void initState() {
    super.initState();
    _cowDataFuture = CattleSyncService.getSingleCow(widget.docId);
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _breedController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _sexController = TextEditingController();
    _healthController = TextEditingController();
  }

  void _populateControllers(CattleRecord data) {
    if (_nameController.text.isEmpty) _nameController.text = data.name;
    if (_breedController.text.isEmpty) _breedController.text = data.breed;
    if (_ageController.text.isEmpty) _ageController.text = data.age;
    if (_weightController.text.isEmpty) _weightController.text = data.weight;
    if (_heightController.text.isEmpty) _heightController.text = data.height;
    if (_sexController.text.isEmpty) _sexController.text = data.sex;
    if (_healthController.text.isEmpty)
      _healthController.text = data.diseasesAilments;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _sexController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  // --- Image Carousel Logic ---

  Widget _buildImageCarousel(CattleRecord data) {
    final images = _getImagesForCarousel(data);

    if (images.isEmpty) {
      return Container(
        height: 289,
        width: double.infinity,
        child: _buildPlaceholderImage(),
      );
    }

    return SizedBox(
      height: 289,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildSingleImage(images[index]);
            },
          ),

          // Navigation Arrows
          if (images.length > 1) ...[
            // Left Arrow
            if (_currentImageIndex > 0)
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios,
                          size: 20, color: Colors.white),
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),

            // Right Arrow
            if (_currentImageIndex < images.length - 1)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios,
                          size: 20, color: Colors.white),
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),

            // Dots Indicator
            Positioned(
              bottom: 60, // Above the pill
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<dynamic> _getImagesForCarousel(CattleRecord data) {
    List<dynamic> images = [];

    // Priority 1: Local paths
    if (data.localImagePaths != null && data.localImagePaths!.isNotEmpty) {
      for (var path in data.localImagePaths!) {
        final file = File(path);
        if (file.existsSync()) {
          images.add(file);
        }
      }
    }

    // Priority 2: info from urls only if local paths are empty (to avoid dups or mixed states usually)
    // Or we could append. For now, following existing logic: prefer local.
    if (images.isEmpty &&
        data.imageUrls != null &&
        data.imageUrls!.isNotEmpty) {
      images.addAll(data.imageUrls!);
    }

    // Priority 3: Single image field fallback
    if (images.isEmpty && data.image != null && data.image!.isNotEmpty) {
      images.add(data.image!);
    }

    return images;
  }

  Widget _buildSingleImage(dynamic imageSource) {
    if (imageSource is File) {
      return Image.file(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 289,
        errorBuilder: (context, error, stack) => _buildPlaceholderImage(),
      );
    } else if (imageSource is String) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 289,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stack) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
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

  // --- Tab Buttons ---

  Widget _buildInfoButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = (text == "Edit");
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? const Color(0x333E9249) : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Info View ---

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

  // --- Edit Logic ---

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      await CattleRepository().updateCattle(
        cattleId: widget.docId,
        name: _nameController.text,
        breed: _breedController.text,
        age: _ageController.text,
        weight: _weightController.text,
        height: _heightController.text,
        sex: _sexController.text,
        diseasesAilments: _healthController.text,
      );

      if (mounted) Navigator.pop(context); // Close loader

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );

      setState(() {
        _isEditing = false;
        _refreshData();
      });
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e')),
      );
    }
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
                    Text('Error loading cow data',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _refreshData, child: const Text('Retry')),
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
                    const Text('Cow not found', style: TextStyle(fontSize: 16)),
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
            // Ensure controllers are populated once
            if (!_isEditing && _nameController.text.isEmpty) {
              _populateControllers(data);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Carousel
                      _buildImageCarousel(data),

                      // App Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          actions: [
                            _buildSyncStatus(data),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              onPressed: _refreshData,
                            ),
                          ],
                        ),
                      ),

                      // Tab Buttons
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
                                _buildInfoButton("Info", !_isEditing),
                                _buildInfoButton("Edit", _isEditing),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Content Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: _isEditing
                        ? _buildEditView(data)
                        : _buildInfoView(data),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoView(CattleRecord data) {
    return Column(
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
        _buildInfoRow("Date Added:",
            data.date != '' ? Utilities.formatShortDateTime(data.date) : 'NA'),
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
    );
  }

  Widget _buildEditView(CattleRecord data) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Edit Information",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064151),
            ),
          ),
          const SizedBox(height: 8),
          // Read-only notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Dates, images, and biometric data cannot be edited.",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField("Name", _nameController),
          _buildTextField("Breed", _breedController),
          _buildTextField("Age", _ageController),
          _buildTextField("Sex", _sexController),
          _buildTextField("Height (m)", _heightController, isNumeric: true),
          _buildTextField("Weight (kg)", _weightController, isNumeric: true),
          _buildTextField("Health Status", _healthController),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064151),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
