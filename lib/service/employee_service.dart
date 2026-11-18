import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _employees =>
      _firestore.collection('employees');

  Stream<List<EmployeeModel>> getEmployees(String ownerId) {
    return _employees
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final result = snapshot.docs.map((doc) {
        return EmployeeModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();

      result.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      return result;
    });
  }

  Future<bool> employeeIdExists({
    required String ownerId,
    required String employeeId,
    String? excludedDocumentId,
  }) async {
    final result = await _employees
        .where('ownerId', isEqualTo: ownerId)
        .where('employeeId', isEqualTo: employeeId)
        .get();

    return result.docs.any(
      (doc) => doc.id != excludedDocumentId,
    );
  }

  Future<void> addEmployee(EmployeeModel employee) async {
    await _employees.add(employee.toMap());
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    if (employee.id.isEmpty) {
      throw Exception('Employee ID is required.');
    }

    final document = _employees.doc(employee.id);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw Exception('Employee not found.');
    }

    if (snapshot.data()?['ownerId'] != employee.ownerId) {
      throw Exception('You are not allowed to update this employee.');
    }

    await document.update(employee.toMap());
  }

  Future<void> deleteEmployee(String employeeId) async {
    await _employees.doc(employeeId).delete();
  }

  Future<EmployeeModel?> getEmployee(String employeeId) async {
    final document = await _employees.doc(employeeId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return EmployeeModel.fromMap(
      document.data()!,
      document.id,
    );
  }
}
