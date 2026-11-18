import '../model/employee_model.dart';
import '../service/employee_service.dart';

class EmployeeController {
  final EmployeeService _service = EmployeeService();

  Stream<List<EmployeeModel>> getEmployees(String ownerId) {
    return _service.getEmployees(ownerId);
  }

  Future<void> addEmployee(EmployeeModel employee) async {
    final exists = await _service.employeeIdExists(
      ownerId: employee.ownerId,
      employeeId: employee.employeeId,
    );

    if (exists) {
      throw Exception('This Employee ID already exists.');
    }

    await _service.addEmployee(employee);
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    final exists = await _service.employeeIdExists(
      ownerId: employee.ownerId,
      employeeId: employee.employeeId,
      excludedDocumentId: employee.id,
    );

    if (exists) {
      throw Exception('This Employee ID already exists.');
    }

    await _service.updateEmployee(employee);
  }

  Future<void> deleteEmployee(String employeeId) {
    return _service.deleteEmployee(employeeId);
  }
}
