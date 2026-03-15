import 'package:flutter/material.dart';
import '../../../core/widgets/otp_primary_button.dart';

class AutopaymentCategory {
  final IconData icon;
  final String label;

  const AutopaymentCategory({
    required this.icon,
    required this.label,
  });
}

class AddAutopaymentSheet extends StatefulWidget {
  final List<AutopaymentCategory> categories;
  final VoidCallback onAdded;

  const AddAutopaymentSheet({
    required this.categories,
    required this.onAdded,
  });

  @override
  State<AddAutopaymentSheet> createState() => AddAutopaymentSheetState();
}

class AddAutopaymentSheetState extends State<AddAutopaymentSheet> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Добавить автоплатеж',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Выберите категорию автоплатежа',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onAdded();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category.icon, color: const Color(0xFF0F172A), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        category.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OtpPrimaryButton(
              label: 'Отмена',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
