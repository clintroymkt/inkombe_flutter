import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkombe_flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';
import '../utils/image_processor.dart';
import '../utils/landmark_extractor.dart';

class CreateCowPage extends StatefulWidget {
  const CreateCowPage({super.key});

  @override
  State<CreateCowPage> createState() => _CreateCowPageState();
}

class _CreateCowPageState extends State<CreateCowPage> {
  final formKey = GlobalKey<FormState>();
  late File? _image = null;
  final picker = ImagePicker();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _breedController = TextEditingController();
  final _sexController = TextEditingController();
  final _diseasesController = TextEditingController();
  List<double> faceEmbeddings = [];
  List<double> noseEmbeddings = [];

  late LandMarkModelRunner landMarkModelRunner;
  late ImageProcessor imageProcessor;

  @override
  void initState() {
    super.initState();

    landMarkModelRunner = LandMarkModelRunner();

    imageProcessor = ImageProcessor(landMarkModelRunner: landMarkModelRunner);
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
    faceEmbeddings;
    noseEmbeddings;
    landMarkModelRunner.dispose();
  }

  var doc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Color(0xFFFFFFFF),
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
                                // Image radius
                                backgroundImage:
                                    _image != null ? FileImage(_image!) : null,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Name'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _ageController,
                                          obscureText: false,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Age'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _heightController,
                                          obscureText: false,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Height(m)'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _weightController,
                                          obscureText: false,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Weight(kg)'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _breedController,
                                          obscureText: false,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Breed'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _sexController,
                                          obscureText: false,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Sex'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: TextFormField(
                                          controller: _diseasesController,
                                          obscureText: false,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Diseases'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        createCow();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color: Color(0xFFd98f48),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Center(
                                          child: Text(
                                            'Add Cow',
                                            style:
                                                TextStyle(color: Colors.white),
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
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  runImageProcessor() async {
    try {
      print("Running the model...");
      final xFile = XFile(_image!.path);
      final output = await imageProcessor.processImage(xFile);
      return output;
    } catch (e, stackTrace) {
      throw Exception("Model execution failed: $e \n $stackTrace");
    } finally {
      setState(() {});
    }
  }

  createCow() async {
    if (_image != null) {

      runImageProcessor().then((output) {
        setState(() {
          faceEmbeddings = output["faceEmbeddings"]!;
          noseEmbeddings = output["noseEmbeddings"]!;
          _image = output["file"];

        });
        DatabaseService().uploadImage(
            _image,
            _ageController.text.trim(),
            _breedController.text.trim(),
            _sexController.text.trim(),
            _diseasesController.text.trim(),
            _heightController.text.trim(),
            _nameController.text.trim(),
            _weightController.text.trim(),
            faceEmbeddings,
            noseEmbeddings
            );
        showSnackBar(context, Colors.greenAccent, "Cow created successfully");
        _ageController.clear();
        _breedController.clear();
        _diseasesController.clear();
        _heightController.clear();
        _nameController.clear();
        _weightController.clear();
      });
    }
  }

  getImage() async {
    // You can also change the source to gallery like this: "source: ImageSource.camera"
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        showSnackBar(
            context, Colors.orange, "Please pick image to create post");
      }
    });
  }
}
