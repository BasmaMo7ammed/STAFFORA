class EmployeeModel {
  final String id;
  final String ownerId;

  final String name;
  final String jobTitle;
  final String department;
  final double salary;
  final String email;
  final String phone;
  final String status;
  final String hireDate;
  final String employeeId;
  final String notes;
  final String address;

  final int avatarIndex;
  final int avatarColor;

  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.jobTitle,
    required this.department,
    required this.salary,
    required this.email,
    required this.phone,
    required this.status,
    required this.hireDate,
    required this.employeeId,
    required this.notes,
    required this.address,
    required this.avatarIndex,
    required this.avatarColor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return EmployeeModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      department: map['department'] ?? '',
      salary: (map['salary'] as num?)?.toDouble() ?? 0,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      status: map['status'] ?? 'Active',
      hireDate: map['hireDate'] ?? '',
      employeeId: map['employeeId'] ?? '',
      notes: map['notes'] ?? '',
      address: map['address'] ?? '',
      avatarIndex: map['avatarIndex'] ?? 1,
      avatarColor: map['avatarColor'] ?? 0xFFD9F0E4,
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value is DateTime) return value;

    if (value != null && value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    if (value != null && value.runtimeType.toString() == 'Timestamp') {
      return value.toDate();
    }

    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'jobTitle': jobTitle,
      'department': department,
      'salary': salary,
      'email': email,
      'phone': phone,
      'status': status,
      'hireDate': hireDate,
      'employeeId': employeeId,
      'notes': notes,
      'address': address,
      'avatarIndex': avatarIndex,
      'avatarColor': avatarColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? jobTitle,
    String? department,
    double? salary,
    String? email,
    String? phone,
    String? status,
    String? hireDate,
    String? employeeId,
    String? notes,
    String? address,
    int? avatarIndex,
    int? avatarColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      employeeId: employeeId ?? this.employeeId,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
