import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neu_card.dart';
import '../../models/material_model.dart';
import '../../controllers/material_controller.dart';
import '../../controllers/auth_controller.dart';

class EditListingView extends StatefulWidget {
  final MaterialModel material;
  
  const EditListingView({super.key, required this.material});

  @override
  State<EditListingView> createState() => _EditListingViewState();
}

class _EditListingViewState extends State<EditListingView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subjectController;
  late TextEditingController _yearController;
  
  late ExamType _selectedExam;
  late MaterialCondition _selectedCondition;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.material.title);
    _descriptionController = TextEditingController(text: widget.material.description);
    _subjectController = TextEditingController(text: widget.material.subject);
    _yearController = TextEditingController(text: widget.material.year);
    
    _selectedExam = widget.material.examType;
    _selectedCondition = widget.material.condition;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final materialController = context.read<MaterialController>();
    final authController = context.read<AuthController>();
    final location = authController.currentUser?.location ?? widget.material.location;

    final success = await materialController.updateListing(
      oldMaterial: widget.material,
      title: _titleController.text,
      description: _descriptionController.text,
      examType: _selectedExam,
      subject: _subjectController.text,
      year: _yearController.text,
      condition: _selectedCondition,
      location: location,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
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
        title: const Text('Edit Listing', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
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
                    // Existing Images Display
                    const Text('Photos (Cannot edit existing photos yet)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.material.imageUrls.map((url) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              url,
                              height: 112,
                              width: 112,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )).toList(),
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
                            "Save Changes",
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
