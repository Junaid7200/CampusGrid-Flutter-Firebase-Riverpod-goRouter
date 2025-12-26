import "package:flutter/material.dart";
import "package:campus_grid/src/shared/widgets/text_field.dart";
import "package:campus_grid/src/shared/widgets/button.dart";
import 'package:campus_grid/src/services/department_service.dart'
    as dept_service;
import 'package:campus_grid/src/services/degree_service.dart' as deg_service;
import 'package:campus_grid/src/services/subject_service.dart' as sub_service;
import 'package:campus_grid/src/services/note_service.dart' as note_service;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class NewResourcePage extends StatefulWidget {
  const NewResourcePage({super.key, this.noteId});
  final String? noteId; // If provided, this is edit mode
  State<NewResourcePage> createState() => _NewResourcePageState();
}

class _NewResourcePageState extends State<NewResourcePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _degrees = [];
  List<Map<String, dynamic>> _subjects = [];

  String? _selectedDeptId;
  String? _selectedDegId;
  String? _selectedSubId;

  File? _selectedFile;
  String? _fileName;

  bool _isLoadingDepts = true;
  bool _isLoadingDegs = false;
  bool _isLoadingSubs = false;
  bool _isUploading = false;
  bool _isEditMode = false;
  String? _existingFileUrl;
  String? _existingFileType;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.noteId != null;
    _loadDepartments();
    if (_isEditMode) {
      _loadExistingNote();
    }
  }

  Future<void> _loadExistingNote() async {
    try {
      final note = await note_service.getNoteById(widget.noteId!);
      if (note != null) {
        _titleController.text = note['title'] ?? '';
        _descController.text = note['description'] ?? '';
        _existingFileUrl = note['fileUrl'];
        _existingFileType = note['fileType'];
        _fileName = note['fileName'];
        _selectedSubId = note['subId'];
        // Note: We don't load dept/deg dropdowns in edit mode
        setState(() {});
      }
    } catch (e) {
      print('Error loading note: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoadingDepts = true);
    try {
      final depts = await dept_service.getDepartments();
      print('Loaded ${depts.length} departments');
      setState(() {
        _departments = depts;
        _isLoadingDepts = false;
      });
    } catch (e) {
      print('Error loading departments: $e');
      setState(() => _isLoadingDepts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading departments: $e')),
        );
      }
    }
  }

  Future<void> _loadDegrees(String deptId) async {
    print('Loading degrees for department: $deptId');
    setState(() {
      _isLoadingDegs = true;
      _selectedDegId = null;
      _selectedSubId = null;
      _degrees = [];
      _subjects = [];
    });

    try {
      final degrees = await deg_service.getDegreesByDepartment(deptId);
      print('Loaded ${degrees.length} degrees');
      if (degrees.isNotEmpty) {
        print('First degree: ${degrees[0]}');
      }

      setState(() {
        _degrees = degrees;
        _isLoadingDegs = false;
      });

      if (degrees.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No degrees found for this department')),
        );
      }
    } catch (e) {
      print('Error loading degrees: $e');
      setState(() => _isLoadingDegs = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading degrees: $e')));
      }
    }
  }

  Future<void> _loadSubjects(String degId) async {
    print('Loading subjects for degree: $degId');
    setState(() {
      _isLoadingSubs = true;
      _selectedSubId = null;
      _subjects = [];
    });

    try {
      final subjects = await sub_service.getSubjectsByDegree(degId);
      print('Loaded ${subjects.length} subjects');

      setState(() {
        _subjects = subjects;
        _isLoadingSubs = false;
      });

      if (subjects.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No subjects found for this degree')),
        );
      }
    } catch (e) {
      print('Error loading subjects: $e');
      setState(() => _isLoadingSubs = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading subjects: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'png',
          'jpg',
          'jpeg',
          'pptx',
          'ppt',
          'docx',
          'doc',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        // Check file size (10MB limit)
        if (fileSizeInMB > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadResource() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditMode && _selectedSubId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a subject')));
      return;
    }

    if (!_isEditMode && _selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a file to upload')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? fileUrl = _existingFileUrl;
      String? fileType = _existingFileType;

      // 1. Upload new file if selected (for both create and edit)
      if (_selectedFile != null) {
        final cloudinary = CloudinaryPublic('djm4otpkd', 'note_files');
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedFile!.path,
            resourceType: CloudinaryResourceType.Auto, // Supports all file types
            folder: 'campus_grid/notes',
          ),
        );
        fileUrl = response.secureUrl;

        // 2. Determine file type
        final fileExtension = _fileName!.split('.').last.toLowerCase();
        fileType = 'document';
        if (fileExtension == 'pdf') {
          fileType = 'pdf';
        } else if (['png', 'jpg', 'jpeg'].contains(fileExtension)) {
          fileType = 'image';
        }
      }

      // 3. Create or update note in Firestore
      if (_isEditMode) {
        await note_service.updateNote(
          noteId: widget.noteId!,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          fileUrl: _selectedFile != null ? fileUrl : null,
          fileName: _selectedFile != null ? _fileName : null,
          fileType: _selectedFile != null ? fileType : null,
        );
      } else {
        await note_service.createNote(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          fileUrl: fileUrl!,
          fileName: _fileName!,
          fileType: fileType!,
          subId: _selectedSubId!,
        );
      }

      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Resource updated successfully!'
                  : 'Resource uploaded successfully!',
            ),
          ),
        );
        context.pop(); // Go back to previous page
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Update failed: $e' : 'Upload failed: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Resource' : 'Upload Resource',
          style: TextStyle(color: colors.primary),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 32, color: colors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                CustomTextField(
                  labelText: "Resource Title",
                  hintText: "e.g., OOP Final Exam Notes",
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                CustomTextField(
                  labelText: "Description",
                  hintText: "Briefly describe your resource",
                  controller: _descController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department Dropdown (only for new resources)
                if (!_isEditMode) ...[
                  Text(
                    "Department",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  _isLoadingDepts
                      ? Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CircularProgressIndicator(),
                        )
                      : DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Select department',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          initialValue: _selectedDeptId,
                          items: _departments.map((dept) {
                            return DropdownMenuItem<String>(
                              value: dept['id'],
                              child: Text(dept['name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            print('Selected department: $value'); // DEBUG
                            setState(() => _selectedDeptId = value);
                            if (value != null) _loadDegrees(value);
                          },
                          validator: (value) {
                            if (value == null)
                              return 'Please select a department';
                            return null;
                          },
                        ),
                  const SizedBox(height: 16),

                  // Degree Dropdown
                  Text("Degree", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  _isLoadingDegs
                      ? Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CircularProgressIndicator(),
                        )
                      : DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: _selectedDeptId == null
                                ? 'Select department first'
                                : _degrees.isEmpty
                                ? 'No degrees available'
                                : 'Select degree',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          initialValue: _selectedDegId,
                          items: _degrees.map((deg) {
                            return DropdownMenuItem<String>(
                              value: deg['id'],
                              child: Text(deg['name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: _selectedDeptId == null || _degrees.isEmpty
                              ? null
                              : (value) {
                                  print('Selected degree: $value'); // DEBUG
                                  setState(() => _selectedDegId = value);
                                  if (value != null) _loadSubjects(value);
                                },
                          validator: (value) {
                            if (value == null) return 'Please select a degree';
                            return null;
                          },
                        ),
                  const SizedBox(height: 16),

                  // Subject Dropdown
                  Text("Subject", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  _isLoadingSubs
                      ? Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CircularProgressIndicator(),
                        )
                      : DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: _selectedDegId == null
                                ? 'Select degree first'
                                : _subjects.isEmpty
                                ? 'No subjects available'
                                : 'Select subject',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          initialValue: _selectedSubId,
                          items: _subjects.map((sub) {
                            return DropdownMenuItem<String>(
                              value: sub['id'],
                              child: Text(sub['name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: _selectedDegId == null || _subjects.isEmpty
                              ? null
                              : (value) {
                                  print('Selected subject: $value'); // DEBUG
                                  setState(() => _selectedSubId = value);
                                },
                          validator: (value) {
                            if (value == null) return 'Please select a subject';
                            return null;
                          },
                        ),
                ],
                const SizedBox(height: 24),

                // File Upload Section
                Text(
                  _isEditMode ? "Upload New File (optional)" : "Upload File",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.outline.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: colors.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 48,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _fileName ?? 'Click to Upload File',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _fileName != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _fileName != null
                                ? colors.primary
                                : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, PNG, JPG (Max 10MB)',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: _isEditMode ? 'Update Resource' : 'Submit Resource',
                  onPressed: _uploadResource,
                  isLoading: _isUploading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
