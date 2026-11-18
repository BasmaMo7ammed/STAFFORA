
import 'package:flutter/material.dart';

import '../../model/employee_model.dart';
import '../../theme/app_colors.dart';

class EmployeeList extends StatelessWidget {
  final List<EmployeeModel> employees;
  final Function(EmployeeModel) onTap;
  final Function(EmployeeModel) onEdit;
  final Function(EmployeeModel) onDelete;

  const EmployeeList({
    super.key,
    required this.employees,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'on leave':
        return AppColors.warning;
      case 'inactive':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _avatar(EmployeeModel employee) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Color(employee.avatarColor),
      child: ClipOval(
        child: Image.asset(
          'assets/avatars/avatar_${employee.avatarIndex}.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 22,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final employee = employees[index];

        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: () => onTap(employee),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _avatar(employee),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          employee.jobTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _statusColor(employee.status),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 5),

                            Text(
                              employee.status,
                              style: TextStyle(
                                color: _statusColor(employee.status),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 35,
                      minHeight: 35,
                    ),
                    iconSize: 19,
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(employee);
                      } else if (value == 'delete') {
                        onDelete(employee);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 19),
                            SizedBox(width: 9),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Text('Delete'),
                          ],
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
}
