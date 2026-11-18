
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/employee_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/employee_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_validators.dart';
import 'custom_button.dart';

class EmployeeFormDialog extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeFormDialog({
    super.key,
    this.employee,
  });

  @override
  State<EmployeeFormDialog> createState() =>
      _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _departmentController;
  late final TextEditingController _salaryController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _notesController;
  late final TextEditingController _addressController;

  String _status = 'Active';
  DateTime _hireDate = DateTime.now();

  int _avatarIndex = 1;
  int _avatarColor = 0xFFD9F0E4;

  bool _isSaving = false;

  final List<int> _avatarColors = [
    0xFFD9F0E4,
    0xFFE8DDF8,
    0xFFFFE1D9,
    0xFFFFEFC2,
    0xFFDDEBFA,
    0xFFF6DCEB,
  ];

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();

    final employee = widget.employee;

    _nameController =
        TextEditingController(text: employee?.name ?? '');
    _jobTitleController =
        TextEditingController(text: employee?.jobTitle ?? '');
    _departmentController =
        TextEditingController(text: employee?.department ?? '');
    _salaryController = TextEditingController(
      text: employee == null ? '' : employee.salary.toString(),
    );
    _emailController =
        TextEditingController(text: employee?.email ?? '');
    _phoneController =
        TextEditingController(text: employee?.phone ?? '');
    _employeeIdController =
        TextEditingController(text: employee?.employeeId ?? '');
    _notesController =
        TextEditingController(text: employee?.notes ?? '');
    _addressController =
        TextEditingController(text: employee?.address ?? '');

    if (employee != null) {
      _status = employee.status;
      _avatarIndex = employee.avatarIndex;
      _avatarColor = employee.avatarColor;

      _hireDate =
          DateTime.tryParse(employee.hireDate) ?? DateTime.now();

      if (!_avatarColors.contains(_avatarColor)) {
        _avatarColor = _avatarColors.first;
      }

      if (_avatarIndex < 1 || _avatarIndex > 6) {
        _avatarIndex = 1;
      }

      if (!['Active', 'Inactive', 'On Leave'].contains(_status)) {
        _status = 'Active';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 20,
      ),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Future<void> _selectHireDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _hireDate = selectedDate;
      });
    }
  }

  Widget _avatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Avatar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(6, (index) {
            final avatarNumber = index + 1;
            final selected = _avatarIndex == avatarNumber;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _avatarIndex = avatarNumber;
                  _avatarColor = _avatarColors[index];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(_avatarColors[index]),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/avatars/avatar_$avatarNumber.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _saveEmployee() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);

    final authUser = context.read<AuthProvider>().currentUser;

    if (authUser == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please sign in again.'),
        ),
      );
      return;
    }

    final salary = double.tryParse(
      _salaryController.text.trim(),
    );

    if (salary == null || !salary.isFinite || salary < 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid salary.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final oldEmployee = widget.employee;

    final employee = EmployeeModel(
      id: oldEmployee?.id ?? '',
      ownerId: oldEmployee?.ownerId ?? authUser.uid,
      name: _nameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      department: _departmentController.text.trim(),
      salary: salary,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      status: _status,
      hireDate: _hireDate.toIso8601String(),
      employeeId: _employeeIdController.text.trim(),
      notes: _notesController.text.trim(),
      address: _addressController.text.trim(),
      avatarIndex: _avatarIndex,
      avatarColor: _avatarColor,
      createdAt: oldEmployee?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final provider = context.read<EmployeeProvider>();

      if (_isEditing) {
        await provider.updateEmployee(employee);
      } else {
        await provider.addEmployee(employee);
      }

      if (!mounted) return;

      final message = _isEditing
          ? 'Employee updated successfully.'
          : 'Employee added successfully.';

      Navigator.pop(context, true);

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not save employee: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 550,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Employee' : 'Add Employee',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const Divider(color: AppColors.border),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Personal Information'),

                        _textField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: AppValidators.required,
                        ),

                        _textField(
                          controller: _employeeIdController,
                          label: 'Employee ID',
                          icon: Icons.badge_outlined,
                          validator: AppValidators.required,
                        ),

                        _avatarSelector(),

                        _sectionTitle('Job Information'),

                        _textField(
                          controller: _jobTitleController,
                          label: 'Job Title',
                          icon: Icons.work_outline,
                          validator: AppValidators.required,
                        ),

                        _textField(
                          controller: _departmentController,
                          label: 'Department',
                          icon: Icons.business_outlined,
                          validator: AppValidators.required,
                        ),

                        _textField(
                          controller: _salaryController,
                          label: 'Salary',
                          icon: Icons.payments_outlined,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: AppValidators.salary,
                        ),

                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: _inputDecoration(
                            'Employment Status',
                            Icons.circle_outlined,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Inactive',
                              child: Text('Inactive'),
                            ),
                            DropdownMenuItem(
                              value: 'On Leave',
                              child: Text('On Leave'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        _sectionTitle('Contact Information'),

                        _textField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.email,
                        ),

                        _textField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.phone,
                        ),

                        _textField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.location_on_outlined,
                        ),

                        _sectionTitle('Additional Information'),

                        InkWell(
                          onTap: _selectHireDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              'Hire Date',
                              Icons.calendar_month_outlined,
                            ),
                            child: Text(
                              '${_hireDate.day}/${_hireDate.month}/${_hireDate.year}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _textField(
                          controller: _notesController,
                          label: 'Notes (Optional)',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                CustomButton(
                  text: _isEditing ? 'Save Changes' : 'Add Employee',
                  onPressed: _saveEmployee,
                  isLoading: _isSaving,
                  icon: _isEditing
                      ? Icons.check
                      : Icons.add,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
