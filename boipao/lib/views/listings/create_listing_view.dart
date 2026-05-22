import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';
import '../../models/material_model.dart';
import '../../controllers/material_controller.dart';
import '../../controllers/auth_controller.dart';

class CreateListingView extends StatefulWidget {
  const CreateListingView({super.key});

  @override
  State<CreateListingView> createState() => _CreateListingViewState();
}

class _CreateListingViewState extends State<CreateListingView> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  
  double? _lat;
  double? _lng;
  bool _isGettingLocation = false;
  
  ExamType _selectedExam = ExamType.ssc;
  MaterialCondition _selectedCondition = MaterialCondition.good;
  
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  /// Opens the device gallery so the user can select multiple photos of their book.
  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    }
  }

  /// Requests location permissions from the user and fetches their current GPS coordinates.
  /// Uses reverse geocoding to translate those coordinates into a readable area name.
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      } 

      Position position = await Geolocator.getCurrentPosition();
      
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String area = place.subLocality ?? place.locality ?? place.administrativeArea ?? 'Unknown Location';
        
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _locationController.text = area;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  /// Triggers when the user taps "Post Listing"
  void _submit() async {
    // 1. Check if all text fields are filled out correctly
    if (!_formKey.currentState!.validate()) return;
    
    // 2. Ensure they actually attached a photo!
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    final materialController = context.read<MaterialController>();
    final authController = context.read<AuthController>();
    
    String finalLocation = _locationController.text.trim();
    if (finalLocation.isEmpty) {
        finalLocation = authController.currentUser?.location ?? 'Dhaka';
    }

    final success = await materialController.createListing(
      title: _titleController.text,
      description: _descriptionController.text,
      examType: _selectedExam,
      subject: _subjectController.text,
      year: _yearController.text,
      condition: _selectedCondition,
      location: finalLocation,
      lat: _lat,
      lng: _lng,
      images: _selectedImages,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(materialController.errorMessage, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MaterialController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('Add Listing', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.iconAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Section
                    const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: NeuCard(
                              padding: 16.0,
                              child: const SizedBox(
                                height: 80,
                                width: 80,
                                child: Icon(Icons.add_a_photo, color: AppColors.iconAccent, size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ..._selectedImages.map((image) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: kIsWeb 
                                    ? Image.network(
                                        image.path,
                                        height: 112,
                                        width: 112,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(image.path),
                                        height: 112,
                                        width: 112,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Inputs
                    _buildTextField(_titleController, "Title", "e.g. HSC Physics 2nd Paper", Icons.book),
                    const SizedBox(height: 16),
                    _buildTextField(_subjectController, "Subject", "e.g. Physics", Icons.subject),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, "Description (Optional)", "Condition details, edition, etc.", Icons.description, maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(_yearController, "Year/Edition", "e.g. 2023", Icons.calendar_today),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_locationController, "Location", "e.g. Uttara (or use GPS)", Icons.location_on),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isGettingLocation ? null : _getCurrentLocation,
                          icon: _isGettingLocation 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, color: AppColors.iconAccent),
                          tooltip: 'Use Current Location',
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dropdowns
                    const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ExamType>(
                            value: _selectedExam,
                            decoration: InputDecoration(
                              labelText: "Exam Type",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: ExamType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.label))).toList(),
                            onChanged: (val) => setState(() => _selectedExam = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<MaterialCondition>(
                            value: _selectedCondition,
                            decoration: InputDecoration(
                              labelText: "Condition",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: MaterialCondition.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                            onChanged: (val) => setState(() => _selectedCondition = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Submit
                    GestureDetector(
                      onTap: _submit,
                      child: NeuCard(
                        color: AppColors.navBar,
                        padding: 16.0,
                        child: const Center(
                          child: Text(
                            "Post Listing",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (val) {
        if (maxLines == 1 && (val == null || val.isEmpty)) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
      ),
    );
  }
}
