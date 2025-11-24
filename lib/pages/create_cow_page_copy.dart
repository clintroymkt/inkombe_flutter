import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inkombe_flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cattle_repository.dart';
import '../services/database_service.dart';
import '../services/network_service.dart';
import '../widgets/list_card.dart';

class CreateCowPageCopy extends StatefulWidget {
  final List<File> pngFilesList;
  final List<List<double>> faceEmbeddingsList;
  final List<List<double>> noseEmbeddingsList;
  const CreateCowPageCopy({
    super.key,
    required this.pngFilesList,
    required this.faceEmbeddingsList,
    required this.noseEmbeddingsList,
  });

  @override
  State<CreateCowPageCopy> createState() => _CreateCowPageCopyState();
}

class _CreateCowPageCopyState extends State<CreateCowPageCopy> {
  final formKey = GlobalKey<FormState>();
  late List<File>? _images = [];
  List<List<double>>? faceEmbeddingsList;
  List<List<double>>? noseEmbeddingsList;
  final picker = ImagePicker();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _breedController = TextEditingController();
  final _sexController = TextEditingController();
  final _diseasesController = TextEditingController();

  final CattleRepository _cattleRepo = CattleRepository();

  @override
  void initState() {
    super.initState();
    setState(() {
      _images = widget.pngFilesList;
      faceEmbeddingsList = widget.faceEmbeddingsList;
      noseEmbeddingsList = widget.noseEmbeddingsList;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _breedController.dispose();
    _sexController.dispose();
    _diseasesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Color(0xFF064151),
                  padding: EdgeInsets.only(top: 41),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 17, left: 18),
                          child: Column(
                            children: [
                              const Text(
                                'Add new Cow',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 24,
                                ),
                              ),
                              InkWell(
                                child: CircleAvatar(
                                  radius: 100,
                                  backgroundImage: _images?[0] != null ? FileImage(_images![0]) : null,
                                ),
                                onTap: () {
                                  getImage();
                                },
                              ),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Name',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _ageController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Age',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _heightController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Height(m)',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _weightController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Weight(kg)',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _breedController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Breed',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _sexController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Sex',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: TextFormField(
                                            controller: _diseasesController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Diseases',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          createCow();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF064151),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Add Cow',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createCow() async {
    if (formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try{
        await _cattleRepo.createCattle(
          // _images?[0],
          // _ageController.text.trim(),
          // _breedController.text.trim(),
          // _sexController.text.trim(),
          // _diseasesController.text.trim(),
          // _heightController.text.trim(),
          // _nameController.text.trim(),
          // _weightController.text.trim(),
          // faceEmbeddingsList!,
          // noseEmbeddingsList!,
          // _ageController.text.trim(),

          age: _ageController.text,
          breed: _breedController.text,
          sex: 'Female', // Get from your form
          diseasesAilments: 'None', // Get from your form
          height: '1.4', // Get from your form
          name: _nameController.text,
          weight: '450', // Get from your form
          images: _images,
          faceEmbeddings: faceEmbeddingsList!,
          noseEmbeddings: noseEmbeddingsList!,
          date: DateTime.now().toString(),
        );
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle saved successfully!')),
        );

        // Check sync status
        final isOnline = await NetworkService.isOnline();
        if (!isOnline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved locally - will sync when online'),
              duration: Duration(seconds: 3),
            ),
          );
        }

      }catch (e){
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving cattle: $e')),
        );
      }
    //   Old implementation
    //   await DatabaseService().uploadImage(
    //     _images?[0],
    //     _ageController.text.trim(),
    //     _breedController.text.trim(),
    //     _sexController.text.trim(),
    //     _diseasesController.text.trim(),
    //     _heightController.text.trim(),
    //     _nameController.text.trim(),
    //     _weightController.text.trim(),
    //     faceEmbeddingsList!,
    //     noseEmbeddingsList!,
    //   );
    //   showSnackBar(context, Colors.greenAccent, "Cow created successfully");
    //   _ageController.clear();
    //   _breedController.clear();
    //   _diseasesController.clear();
    //   _heightController.clear();
    //   _nameController.clear();
    //   _weightController.clear();
     }
  }


  getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _images = File(pickedFile.path) as List<File>?;
      } else {
        showSnackBar(context, Colors.orange, "Please pick an image to create a post");
      }
    });
  }
}