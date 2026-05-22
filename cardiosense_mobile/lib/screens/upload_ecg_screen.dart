import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';

class UploadEcgScreen extends StatefulWidget {
  const UploadEcgScreen({Key? key}) : super(key: key);

  @override
  State<UploadEcgScreen> createState() => _UploadEcgScreenState();
}

class _UploadEcgScreenState extends State<UploadEcgScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = '';
  PlatformFile? _selectedFile;
  String _errorText = '';
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (_) {
      // Permission denied or file picking cancelled
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _errorText = '';
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final reportService = Provider.of<ReportService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      setState(() {
        _errorText = 'No logged in user found.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Perform multi-part upload to Node.js backend
      await reportService.uploadReport(
        patientName: _nameController.text,
        patientEmail: _emailController.text,
        patientAge: _ageController.text,
        patientGender: _selectedGender,
        symptoms: _symptomsController.text,
        notes: _notesController.text,
        cardiologistName: user.name,
        cardiologistEmail: user.email,
        filePath: _selectedFile?.path,
        fileBytes: _selectedFile?.bytes,
        fileName: _selectedFile?.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ECG uploaded and analyzed by AI successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Clear fields on success
        _nameController.clear();
        _emailController.clear();
        _ageController.clear();
        _symptomsController.clear();
        _notesController.clear();
        setState(() {
          _selectedFile = null;
          _selectedGender = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload ECG for AI Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload a patient\'s physical ECG scan (PDF) to start automated arrhythmia detection.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Form container
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // File Upload Dropzone
                      const Text(
                        'ECG Scanning PDF Document',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedFile != null ? const Color(0xFF0A66C2) : const Color(0xFFE5E7EB),
                              width: 1.5,
                              style: _selectedFile != null ? BorderStyle.solid : BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFile != null ? Icons.file_present_rounded : Icons.upload_file_rounded,
                                color: const Color(0xFF0A66C2),
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFile != null
                                    ? _selectedFile!.name
                                    : 'Select Patient ECG Report PDF',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFile != null
                                    ? '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                                    : '(Tap to select from storage or simulate)',
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Patient Identification Details',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 12),

                      // Patient Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'e.g. John Doe',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Patient name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Patient Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'e.g. patient@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Patient email is required.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age & Gender row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                hintText: 'e.g. 45',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Age required.';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Enter a number.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender.isEmpty ? null : _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                              ),
                              hint: const Text('Select...'),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedGender = val;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Symptoms
                      TextFormField(
                        controller: _symptomsController,
                        decoration: const InputDecoration(
                          labelText: 'Symptoms Observed',
                          hintText: 'e.g. Chest pain, palpitations',
                          prefixIcon: Icon(Icons.healing_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Clinical Notes & Medical History',
                          hintText: 'Enter secondary symptoms or cardiovascular histories...',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 40.0),
                            child: Icon(Icons.notes),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error message
                      if (_errorText.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(
                            _errorText,
                            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Upload Button
                      ElevatedButton(
                        onPressed: _isUploading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A66C2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                        child: _isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'AI Analyzing & Scanning...',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : const Text(
                                'Upload & AI Analyze',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
    );
  }
}
