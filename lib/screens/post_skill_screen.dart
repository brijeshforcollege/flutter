import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Session Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_selectedDate.toLocal()}".split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("User not logged in.");
        }

        // Get user data from Firestore (if you store additional user info there)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
        final userName = userData?['name']?.toString() ?? user.displayName ?? 'Anonymous';

        // Generate dummy Google Meet link
        String meetLink = "https://meet.google.com/${DateTime.now().millisecondsSinceEpoch}";

        final skillData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'teacherId': user.uid,
          'teacherName': userName,
          'teacherEmail': user.email,
          'teacherImage': user.photoURL ?? '', // or use placeholder
          'timeSlot': _selectedTimeSlot,
          'category': _selectedCategory,
          'skillCoins': int.parse(_coinsController.text),
          'maxParticipants': int.parse(_maxParticipantsController.text),
          'currentParticipants': 0,
          'datePosted': Timestamp.now(),
          'scheduledDate': Timestamp.fromDate(_selectedDate),
          'meetLink': meetLink,
          'status': 'upcoming', // can be 'upcoming', 'completed', 'cancelled'
        };

        await FirebaseFirestore.instance.collection('skills').add(skillData);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill posted successfully!')),
        );
      } catch (e) {
        debugPrint('Error posting skill: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post skill: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}