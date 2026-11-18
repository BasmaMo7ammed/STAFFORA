
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/employee_model.dart';
import '../provider/auth_provider.dart';
import '../provider/employee_provider.dart';
import '../theme/app_colors.dart';

import 'components/employee_form_dialog.dart';

import '../wedgit/employee_empty_list.dart';
import '../wedgit/employee_empty_grid.dart';
import '../wedgit/employee_list.dart';
import '../wedgit/employee_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedDepartment = 'All';

  bool _isGridView = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().currentUser;

      if (user != null) {
        context
            .read<EmployeeProvider>()
            .listenToEmployees(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter Employees
  List<EmployeeModel> _filterEmployees(
    List<EmployeeModel> employees,
  ) {
    final departmentExists = employees.any(
      (employee) =>
          employee.department == _selectedDepartment,
    );

    final selectedDepartment =
        _selectedDepartment == 'All' || departmentExists
            ? _selectedDepartment
            : 'All';

    return employees.where((employee) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          employee.name.toLowerCase().contains(query) ||
          employee.employeeId.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query) ||
          employee.jobTitle.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == 'All' ||
          employee.status == _selectedStatus;

      final matchesDepartment =
          selectedDepartment == 'All' ||
          employee.department == selectedDepartment;

      return matchesSearch &&
          matchesStatus &&
          matchesDepartment;
    }).toList();
  }

  // Add / Edit Employee
  Future<void> _showEmployeeForm({
    EmployeeModel? employee,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => EmployeeFormDialog(
        employee: employee,
      ),
    );
  }

  // Employee Details
  Future<void> _showEmployeeDetails(
    EmployeeModel employee,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ),

                  CircleAvatar(
                    radius: 43,
                    backgroundColor: Color(employee.avatarColor),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/avatars/avatar_${employee.avatarIndex}.png',
                        width: 86,
                        height: 86,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.person,
                            size: 43,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    employee.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    employee.jobTitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(color: AppColors.border),

                  _detailRow(
                    'Employee ID',
                    employee.employeeId,
                  ),
                  _detailRow(
                    'Department',
                    employee.department,
                  ),
                  _detailRow(
                    'Salary',
                    NumberFormat.currency(
                      symbol: '\$',
                      decimalDigits: 2,
                    ).format(employee.salary),
                  ),
                  _detailRow('Email', employee.email),
                  _detailRow('Phone', employee.phone),
                  _detailRow('Status', employee.status),
                  _detailRow(
                    'Hire Date',
                    _formatDate(employee.hireDate),
                  ),
                  _detailRow('Address', employee.address),
                  _detailRow('Notes', employee.notes),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            _showEmployeeForm(
                              employee: employee,
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Details Row
  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format Date
  String _formatDate(String date) {
    final parsed = DateTime.tryParse(date);

    if (parsed == null) return date;

    return DateFormat('dd MMM yyyy').format(parsed);
  }

  // Delete Employee
  Future<void> _deleteEmployee(
    EmployeeModel employee,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Delete Employee?'),
          content: Text(
            'Are you sure you want to delete ${employee.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await context
          .read<EmployeeProvider>()
          .deleteEmployee(employee.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete employee: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // STAFFORA Gradient Overview Card
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color accentColor,
    required Color gradientEnd,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.09),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 19,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dashboard
  Widget _buildDashboard(
    List<EmployeeModel> employees,
  ) {
    final total = employees.length;

    final active = employees
        .where((e) => e.status == 'Active')
        .length;

    final inactive = employees
        .where((e) => e.status == 'Inactive')
        .length;

    final onLeave = employees
        .where((e) => e.status == 'On Leave')
        .length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: [
        _statCard(
          title: 'Total Employees',
          value: '$total',
          icon: Icons.groups_rounded,
          backgroundColor: const Color(0xFFDCEDE3),
          gradientEnd: const Color(0xFFB9DCCB),
          accentColor: const Color(0xFF174C39),
        ),

        _statCard(
          title: 'Active Employees',
          value: '$active',
          icon: Icons.check_circle_rounded,
          backgroundColor: const Color(0xFFD5EEE3),
          gradientEnd: const Color(0xFFA9DCC5),
          accentColor: const Color(0xFF287A5B),
        ),

        _statCard(
          title: 'Inactive Employees',
          value: '$inactive',
          icon: Icons.person_off_rounded,
          backgroundColor: const Color(0xFFF8E6DF),
          gradientEnd: const Color(0xFFF2CFC5),
          accentColor: const Color(0xFFA85F52),
        ),

        _statCard(
          title: 'On Leave',
          value: '$onLeave',
          icon: Icons.event_busy_rounded,
          backgroundColor: const Color(0xFFF5EEDC),
          gradientEnd: const Color(0xFFE9DDBD),
          accentColor: const Color(0xFF94743E),
        ),
      ],
    );
  }

  // Search and Filters
  Widget _buildFilters(
    List<EmployeeModel> employees,
  ) {
    final departments = employees
        .map((e) => e.department)
        .where((department) => department.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final selectedDepartment =
        departments.contains(_selectedDepartment) ||
                _selectedDepartment == 'All'
            ? _selectedDepartment
            : 'All';

    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by name, ID, email...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Status',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'All',
                    child: Text('All Status'),
                  ),
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
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedDepartment,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Department',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'All',
                    child: Text('All Departments'),
                  ),

                  ...departments.map(
                    (department) => DropdownMenuItem(
                      value: department,
                      child: Text(
                        department,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Employee Section
  Widget _buildEmployeeSection(
    List<EmployeeModel> employees,
    List<EmployeeModel> filteredEmployees,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Employees',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            IconButton(
              tooltip: 'List View',
              onPressed: () {
                setState(() {
                  _isGridView = false;
                });
              },
              icon: Icon(
                Icons.view_list_rounded,
                color: !_isGridView
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),

            IconButton(
              tooltip: 'Grid View',
              onPressed: () {
                setState(() {
                  _isGridView = true;
                });
              },
              icon: Icon(
                Icons.grid_view_rounded,
                color: _isGridView
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (filteredEmployees.isEmpty && employees.isEmpty)
          SizedBox(
            height: 320,
            child: _isGridView
                ? EmployeeEmptyGrid(
                    onAddEmployee: () =>
                        _showEmployeeForm(),
                  )
                : EmployeeEmptyList(
                    onAddEmployee: () =>
                        _showEmployeeForm(),
                  ),
          )
        else if (filteredEmployees.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 45),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: AppColors.textSecondary,
                    size: 45,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No matching employees found.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_isGridView)
          EmployeeGrid(
            employees: filteredEmployees,
            onTap: _showEmployeeDetails,
            onEdit: (employee) {
              _showEmployeeForm(employee: employee);
            },
            onDelete: _deleteEmployee,
          )
        else
          EmployeeList(
            employees: filteredEmployees,
            onTap: _showEmployeeDetails,
            onEdit: (employee) {
              _showEmployeeForm(employee: employee);
            },
            onDelete: _deleteEmployee,
          ),
      ],
    );
  }

  // Logout
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context
        .read<EmployeeProvider>()
        .clearEmployees();

    await context.read<AuthProvider>().logout();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final employeeProvider =
        context.watch<EmployeeProvider>();

    final authProvider =
        context.watch<AuthProvider>();

    final employees = employeeProvider.employees;

    final filteredEmployees =
        _filterEmployees(employees);

    final adminName =
        authProvider.currentUser?.displayName ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'STAFFORA',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Log Out',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),

      body: SafeArea(
        child: employeeProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $adminName 👋',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Here is what is happening with your team today.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Overview',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildDashboard(employees),

                    const SizedBox(height: 30),

                    _buildFilters(employees),

                    const SizedBox(height: 25),

                    _buildEmployeeSection(
                      employees,
                      filteredEmployees,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
