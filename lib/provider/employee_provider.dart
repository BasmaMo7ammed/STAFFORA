import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/employee_controller.dart';
import '../model/employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeController _controller = EmployeeController();

  StreamSubscription<List<EmployeeModel>>? _subscription;

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedDepartment = 'All';

  bool _isGridView = false;

  // Getters
  List<EmployeeModel> get employees => _employees;

  List<EmployeeModel> get filteredEmployees => _filteredEmployees;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get selectedStatus => _selectedStatus;

  String get selectedDepartment => _selectedDepartment;

  bool get isGridView => _isGridView;

  int get totalEmployees => _employees.length;

  int get activeEmployees =>
      _employees.where((e) => e.status == 'Active').length;

  int get inactiveEmployees =>
      _employees.where((e) => e.status == 'Inactive').length;

  int get employeesOnLeave =>
      _employees.where((e) => e.status == 'On Leave').length;

  double get totalSalary =>
      _employees.fold(0.0, (total, employee) => total + employee.salary);

  List<String> get departments {
    final values = _employees
        .map((employee) => employee.department)
        .where((department) => department.trim().isNotEmpty)
        .toSet()
        .toList();

    values.sort();
    return values;
  }

  // Listen to Firestore employees
  void listenToEmployees(String ownerId) {
    _subscription?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _controller.getEmployees(ownerId).listen(
      (employees) {
        _employees = employees;
        _applyFilters();

        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Unable to load employees.';
        notifyListeners();
      },
    );
  }

  // Search
  void setSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Status filter
  void setStatusFilter(String value) {
    _selectedStatus = value;
    _applyFilters();
    notifyListeners();
  }

  // Department filter
  void setDepartmentFilter(String value) {
    _selectedDepartment = value;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = 'All';
    _selectedDepartment = 'All';

    _applyFilters();
    notifyListeners();
  }

  // Toggle List / Grid
  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void setGridView(bool value) {
    _isGridView = value;
    notifyListeners();
  }

  // Apply search and filters
  void _applyFilters() {
    _filteredEmployees = _employees.where((employee) {
      final matchesSearch =
          employee.name.toLowerCase().contains(_searchQuery) ||
          employee.jobTitle.toLowerCase().contains(_searchQuery) ||
          employee.department.toLowerCase().contains(_searchQuery) ||
          employee.email.toLowerCase().contains(_searchQuery) ||
          employee.employeeId.toLowerCase().contains(_searchQuery);

      final matchesStatus = _selectedStatus == 'All' ||
          employee.status == _selectedStatus;

      final matchesDepartment = _selectedDepartment == 'All' ||
          employee.department == _selectedDepartment;

      return matchesSearch && matchesStatus && matchesDepartment;
    }).toList();
  }

  // Add employee
  Future<void> addEmployee(EmployeeModel employee) async {
    await _controller.addEmployee(employee);
  }

  // Update employee
  Future<void> updateEmployee(EmployeeModel employee) async {
    await _controller.updateEmployee(employee);
  }

  // Delete employee
  Future<void> deleteEmployee(String employeeId) async {
    await _controller.deleteEmployee(employeeId);
  }

  // Clear employees on logout
  void clearEmployees() {
    _subscription?.cancel();
    _subscription = null;

    _employees = [];
    _filteredEmployees = [];

    _searchQuery = '';
    _selectedStatus = 'All';
    _selectedDepartment = 'All';

    _isLoading = false;
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
