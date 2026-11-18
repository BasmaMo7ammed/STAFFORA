import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EmployeeEmptyGrid extends StatelessWidget {
  final VoidCallback onAddEmployee;

  const EmployeeEmptyGrid({
    super.key,
    required this.onAddEmployee,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.grid_view_rounded,
              size: 75,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 18),
            const Text(
              'Your team is waiting!',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add employees to see them organized here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddEmployee,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add First Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}