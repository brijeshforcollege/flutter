import 'package:flutter/material.dart';
import 'package:skillxchange/data/mock_data.dart';
import 'package:skillxchange/models/skill_model.dart';

class PostSkillScreen extends StatefulWidget {
  const PostSkillScreen({super.key});

  @override
  State<PostSkillScreen> createState() => _PostSkillScreenState();
}

class _PostSkillScreenState extends State<PostSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coinsController = TextEditingController(text: '30');
  final _maxParticipantsController = TextEditingController(text: '10');
  String _selectedCategory = 'Programming';
  String _selectedTimeSlot = '10:00 AM - 12:00 PM';
  bool _isLoading = false;

  final List<String> _categories = [
    'Programming',
    'Art',
    'Music',
    'Cooking',
    'Language',
    'Business',
  ];

  final List<String> _timeSlots = [
    '10:00 AM - 12:00 PM',
    '2:00 PM - 4:00 PM',
    '6:00 PM - 8:00 PM',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coinsController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Skill'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Post'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Skill Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTimeSlot,
                      decoration: const InputDecoration(
                        labelText: 'Time Slot',
                        border: OutlineInputBorder(),
                      ),
                      items: _timeSlots
                          .map((slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeSlot = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _coinsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Skill Coins',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter coins';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxParticipantsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Participants',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Post Skill',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      Future.delayed(const Duration(seconds: 2), () {
        final newSkill = Skill(
          id: '${mockSkills.length + 1}',
          title: _titleController.text,
          description: _descriptionController.text,
          teacherName: currentUser.name,
          teacherImage: currentUser.imageUrl,
          timeSlot: _selectedTimeSlot,
          skillCoins: int.parse(_coinsController.text),
          date: DateTime.now().add(const Duration(days: 7)),
          category: _selectedCategory,
          maxParticipants: int.parse(_maxParticipantsController.text),
          currentParticipants: 0,
        );

        mockSkills.insert(0, newSkill);
        
        setState(() {
          _isLoading = false;
        });
        
        Navigator.pop(context);
      });
    }
  }
}