import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/provider_profile_provider.dart';
import '../../providers/job_type_provider.dart';
import '../../../domain/models/job_type.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  List<JobType> _selectedJobTypes = [];
  bool _isEditing = false; // To differentiate between create and update

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _addressController = TextEditingController();
    // Fetch profile and job types when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerProfileProvider = context.read<ProviderProfileProvider>();
      final jobTypeProvider = context.read<JobTypeProvider>();

      providerProfileProvider.fetchProviderProfile().then((hasProfile) {
        if (hasProfile && providerProfileProvider.profile != null) {
          setState(() {
            _isEditing = true;
            _bioController.text = providerProfileProvider.profile!.bio ?? '';
            _addressController.text = providerProfileProvider.profile!.address;
            _selectedJobTypes = List.from(providerProfileProvider.profile!.jobTypes);
          });
        }
      });
      jobTypeProvider.fetchJobTypes();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ProviderProfileProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateProviderProfile(
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        address: _addressController.text,
        jobTypeIds: _selectedJobTypes.map((e) => e.id).toList(),
      );
    } else {
      success = await provider.createProviderProfile(
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        address: _addressController.text,
        jobTypeIds: _selectedJobTypes.map((e) => e.id).toList(),
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Profile updated successfully!' : 'Profile created successfully!')),
      );
      if (!_isEditing) {
        // After creating a profile, set _isEditing to true to allow updates next time
        setState(() {
          _isEditing = true;
        });
      }
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${provider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Create Profile'),
        centerTitle: true,
      ),
      body: Consumer2<ProviderProfileProvider, JobTypeProvider>(
        builder: (context, providerProfileProvider, jobTypeProvider, child) {
          if (providerProfileProvider.isLoading || jobTypeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (providerProfileProvider.error != null) {
            return Center(
              child: Text('Error: ${providerProfileProvider.error}'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio (Optional)',
                      hintText: 'Tell us about yourself and your experience',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Your current address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Job Types:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0, // horizontal spacing between buttons
                    runSpacing: 8.0, // vertical spacing between lines of buttons
                    children: jobTypeProvider.jobTypes.map((jobType) {
                      final isSelected = _selectedJobTypes.contains(jobType);
                      return TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                          backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: isSelected ? BorderSide(color: AppTheme.primaryColor) : BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              _selectedJobTypes.remove(jobType);
                            } else {
                              _selectedJobTypes.add(jobType);
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              jobType.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedJobTypes.isEmpty && (_formKey.currentState?.validate() ?? false)) // Simple validation hint
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Text(
                        'Please select at least one job type',
                        style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: providerProfileProvider.isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: providerProfileProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditing ? 'Update Profile' : 'Create Profile',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 