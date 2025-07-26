import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../view_models/subnet_calculator_view_model.dart';

class SubnetInputForm extends StatefulWidget {
  const SubnetInputForm({super.key});

  @override
  State<SubnetInputForm> createState() => _SubnetInputFormState();
}

class _SubnetInputFormState extends State<SubnetInputForm> {
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _maskOrCidrController = TextEditingController();

  @override
  void dispose() {
    _ipAddressController.dispose();
    _maskOrCidrController.dispose();
    super.dispose();
  }

  void _initializeControllers(SubnetCalculatorViewModel viewModel) {
    // Initialize controllers with current ViewModel values
    if (_ipAddressController.text != viewModel.ipAddress) {
      _ipAddressController.text = viewModel.ipAddress;
    }
    if (_maskOrCidrController.text != viewModel.maskOrCidr) {
      _maskOrCidrController.text = viewModel.maskOrCidr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubnetCalculatorViewModel>(
      builder: (context, viewModel, child) {
        // Initialize controllers with ViewModel values
        _initializeControllers(viewModel);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'คำนวณ Subnet', // 'Subnet Calculation' in Thai
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // IP Address input
                TextFormField(
                  controller: _ipAddressController,
                  decoration: InputDecoration(
                    labelText: 'IP Address',
                    hintText:
                        '192.168.1.100 หรือ 192.168.1.100/24', // 'or 192.168.1.100/24' in Thai
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.computer),
                    helperText:
                        'ใส่ IP Address พร้อม CIDR (ทางเลือก)', // 'Enter IP Address with CIDR (optional)' in Thai
                    helperMaxLines: 2,
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    viewModel.updateIpAddress(value);
                  },
                ),
                const SizedBox(height: 16),

                // Subnet Mask or CIDR input
                TextFormField(
                  controller: _maskOrCidrController,
                  decoration: InputDecoration(
                    labelText:
                        'Subnet Mask หรือ CIDR', // 'Subnet Mask or CIDR' in Thai
                    hintText: '255.255.255.0 หรือ 24', // 'or 24' in Thai
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.network_check),
                    helperText:
                        'ใส่ Subnet Mask (255.255.255.0) หรือ CIDR (24)', // 'Enter Subnet Mask or CIDR' in Thai
                    helperMaxLines: 2,
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    viewModel.updateMaskOrCidr(value);
                  },
                ),

                if (viewModel.hasCalculationError) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.calculationError!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isLoading
                            ? null
                            : () {
                                viewModel.calculateSubnet();
                              },
                        icon: viewModel.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.calculate),
                        label: Text(
                          viewModel.isLoading
                              ? 'กำลังคำนวณ...'
                              : 'คำนวณ', // 'Calculating...' : 'Calculate' in Thai
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              _ipAddressController.clear();
                              _maskOrCidrController.clear();
                              viewModel.clearCalculationInputs();
                            },
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'ล้างข้อมูลทั้งหมด', // 'Clear all data' in Thai
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),

                // Quick examples
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                Text(
                  'ตัวอย่าง:', // 'Examples:' in Thai
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildExampleChip(context, '192.168.1.100/24', viewModel),
                    _buildExampleChip(context, '10.0.0.1/8', viewModel),
                    _buildExampleChip(context, '172.16.0.1/16', viewModel),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExampleChip(
    BuildContext context,
    String example,
    SubnetCalculatorViewModel viewModel,
  ) {
    return ActionChip(
      label: Text(example, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        final parts = example.split('/');
        if (parts.length == 2) {
          viewModel.updateIpAddress(parts[0]);
          viewModel.updateMaskOrCidr(parts[1]);
        }
      },
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 12,
      ),
    );
  }
}
