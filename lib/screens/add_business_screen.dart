import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business_store.dart';
import '../theme/app_colors.dart';


class AddBusinessScreen extends StatefulWidget {
  final VoidCallback onBusinessCreated;

  const AddBusinessScreen({super.key, required this.onBusinessCreated});

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final businessNameController = TextEditingController();
  final locationController = TextEditingController();
  final yearsOperatingController = TextEditingController();

  String? selectedBusinessType;
  String? selectedSector;

  @override
  void dispose() {
    businessNameController.dispose();
    locationController.dispose();
    yearsOperatingController.dispose();
    super.dispose();
  }

  void _createBusiness() {
    if (!_formKey.currentState!.validate()) return;

    final int years = int.tryParse(yearsOperatingController.text) ?? 0;

    final business = Business(
      name: businessNameController.text.trim(),
      businessType: selectedBusinessType ?? '',
      sector: selectedSector ?? '',
      location: locationController.text.trim(),
      yearsOperating: years,
    );

    BusinessStore.instance.addBusiness(business);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${business.name} added — identified and details collected.')),
    );

    widget.onBusinessCreated();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Business',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 30),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Business Information', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 5),
          const Text(
            'Tell us about the business you want to add.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 25),
          _responsiveRow(
            _field(
              label: 'Business Name',
              hint: 'e.g. Sunrise Foods Ltd',
              icon: Icons.business_outlined,
              controller: businessNameController,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            _picker(
              label: 'Business Type',
              hint: 'Select business type',
              value: selectedBusinessType,
              items: const ['Sole Proprietorship', 'Partnership', 'Limited Company', 'Other'],
              onChanged: (v) => setState(() => selectedBusinessType = v),
            ),
          ),
          const SizedBox(height: 20),
          _responsiveRow(
            _picker(
              label: 'Business Sector',
              hint: 'Select sector',
              value: selectedSector,
              items: const [
                'Retail & Trading',
                'Food & Hospitality',
                'Manufacturing & Production',
                'Services',
                'Technology & Digital',
                'Construction & Real Estate',
                'Other',
              ],
              onChanged: (v) => setState(() => selectedSector = v),
            ),
            _field(
              label: 'Business Location',
              hint: 'e.g. Accra, Ghana',
              icon: Icons.location_on_outlined,
              controller: locationController,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ),
          const SizedBox(height: 20),
          _field(
            label: 'Years Operating',
            hint: 'e.g. 5',
            icon: Icons.calendar_today_outlined,
            controller: yearsOperatingController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createBusiness,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: const Text('Add Business  →', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveRow(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              Expanded(child: left),
              const SizedBox(width: 15),
              Expanded(child: right),
            ],
          );
        }
        return Column(children: [left, const SizedBox(height: 18), right]);
      },
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 19)),
        ),
      ],
    );
  }

  Widget _picker({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 7),
        InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => _showPickerSheet(
            label: label,
            items: items,
            selected: value,
            onChanged: onChanged,
          ),
          child: InputDecorator(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.tune, size: 19)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: value == null ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textPrimary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPickerSheet({
    required String label,
    required List<String> items,
    required String? selected,
    required ValueChanged<String?> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == selected;
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primaryBlue, size: 20)
                            : null,
                        onTap: () {
                          onChanged(item);
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}