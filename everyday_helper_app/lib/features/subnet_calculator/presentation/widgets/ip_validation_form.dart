import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/models/subnet_validation_result.dart';
import '../view_models/subnet_calculator_view_model.dart';

class IpValidationForm extends StatefulWidget {
  const IpValidationForm({super.key});

  @override
  State<IpValidationForm> createState() => _IpValidationFormState();
}

class _IpValidationFormState extends State<IpValidationForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _multipleIpsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _multipleIpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubnetCalculatorViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ตรวจสอบ IP ในเครือข่าย', // 'IP Network Validation' in Thai
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Network specification inputs
                _buildNetworkInputs(viewModel),

                const SizedBox(height: 16),

                // Tabs for single vs multiple IP validation
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'IP เดียว'), // 'Single IP' in Thai
                    Tab(text: 'หลาย IP'), // 'Multiple IPs' in Thai
                  ],
                ),

                const SizedBox(height: 16),

                // Tab content
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSingleIpTab(viewModel),
                      _buildMultipleIpsTab(viewModel),
                    ],
                  ),
                ),

                if (viewModel.hasValidationError) ...[
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
                            viewModel.validationError!,
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

                const SizedBox(height: 16),

                // Validation results
                if (viewModel.hasValidationResults) ...[
                  _buildValidationResults(viewModel),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkInputs(SubnetCalculatorViewModel viewModel) {
    return Column(
      children: [
        // Network Address input
        TextFormField(
          initialValue: viewModel.networkAddress,
          decoration: InputDecoration(
            labelText: 'Network Address',
            hintText:
                '192.168.1.0 หรือ 192.168.1.0/24', // 'or 192.168.1.0/24' in Thai
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.router),
            helperText:
                'ใส่ Network Address ของเครือข่ายที่ต้องการตรวจสอบ', // 'Enter network address to validate against' in Thai
          ),
          keyboardType: TextInputType.text,
          onChanged: viewModel.updateNetworkAddress,
        ),
        const SizedBox(height: 16),

        // Subnet Mask or CIDR input
        TextFormField(
          initialValue: viewModel.networkMaskOrCidr,
          decoration: InputDecoration(
            labelText: 'Subnet Mask หรือ CIDR', // 'Subnet Mask or CIDR' in Thai
            hintText: '255.255.255.0 หรือ 24', // 'or 24' in Thai
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.network_check),
            helperText:
                'ใส่ Subnet Mask หรือ CIDR ของเครือข่าย', // 'Enter subnet mask or CIDR of the network' in Thai
          ),
          keyboardType: TextInputType.text,
          onChanged: viewModel.updateNetworkMaskOrCidr,
        ),
      ],
    );
  }

  Widget _buildSingleIpTab(SubnetCalculatorViewModel viewModel) {
    return Column(
      children: [
        // Single IP input
        TextFormField(
          initialValue: viewModel.testIpAddress,
          decoration: InputDecoration(
            labelText:
                'IP Address ที่ต้องการตรวจสอบ', // 'IP Address to validate' in Thai
            hintText: '192.168.1.100',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.computer),
          ),
          keyboardType: TextInputType.text,
          onChanged: viewModel.updateTestIpAddress,
        ),
        const SizedBox(height: 16),

        // Validate button
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        viewModel.validateSingleIP();
                      },
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_user),
                label: Text(
                  viewModel.isLoading
                      ? 'กำลังตรวจสอบ...'
                      : 'ตรวจสอบ', // 'Validating...' : 'Validate' in Thai
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      viewModel.clearValidationInputs();
                    },
              icon: const Icon(Icons.clear),
              label: const Text('ล้าง'), // 'Clear' in Thai
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultipleIpsTab(SubnetCalculatorViewModel viewModel) {
    return Column(
      children: [
        // Multiple IPs input
        Expanded(
          child: TextFormField(
            controller: _multipleIpsController,
            decoration: InputDecoration(
              labelText:
                  'IP Addresses (หลาย IP)', // 'IP Addresses (Multiple IPs)' in Thai
              hintText: '192.168.1.100\n192.168.1.101, 192.168.1.102\n10.0.0.1',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              helperText:
                  'ใส่ IP Address หลายตัว คั่นด้วยเครื่องหมายจุลภาค หรือขึ้นบรรทัดใหม่', // 'Enter multiple IP addresses separated by comma or new line' in Thai
              helperMaxLines: 2,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 16),

        // Validate multiple button
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        viewModel.validateMultipleIPs(
                          _multipleIpsController.text,
                        );
                      },
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.playlist_add_check),
                label: Text(
                  viewModel.isLoading
                      ? 'กำลังตรวจสอบ...'
                      : 'ตรวจสอบทั้งหมด', // 'Validating...' : 'Validate All' in Thai
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      _multipleIpsController.clear();
                      viewModel.clearValidationInputs();
                    },
              icon: const Icon(Icons.clear),
              label: const Text('ล้าง'), // 'Clear' in Thai
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValidationResults(SubnetCalculatorViewModel viewModel) {
    final summary = viewModel.getValidationSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),

        // Results summary
        Row(
          children: [
            Icon(
              Icons.assessment,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'ผลการตรวจสอบ', // 'Validation Results' in Thai
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Spacer(),
            Text(
              viewModel.formatValidationResults(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Results list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.validationResults.length,
            itemBuilder: (context, index) {
              final result = viewModel.validationResults[index];
              return _buildValidationResultItem(result);
            },
          ),
        ),

        if (viewModel.validationResults.length > 1) ...[
          const SizedBox(height: 12),
          _buildValidationSummaryCard(summary),
        ],
      ],
    );
  }

  Widget _buildValidationResultItem(SubnetValidationResult result) {
    Color statusColor;
    IconData statusIcon;

    switch (result.status) {
      case ValidationStatus.valid:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ValidationStatus.outOfRange:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case ValidationStatus.invalid:
      case ValidationStatus.invalidFormat:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          result.testIpAddress,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(result.message),
        trailing: Text(
          result.statusDisplay,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildValidationSummaryCard(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'สรุปผลการตรวจสอบ', // 'Validation Summary' in Thai
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'ทั้งหมด',
                summary['total'].toString(),
                Colors.blue,
              ), // 'Total' in Thai
              _buildSummaryItem(
                'ในเครือข่าย',
                summary['valid'].toString(),
                Colors.green,
              ), // 'In Network' in Thai
              _buildSummaryItem(
                'นอกเครือข่าย',
                summary['outOfRange'].toString(),
                Colors.orange,
              ), // 'Out of Network' in Thai
              _buildSummaryItem(
                'ไม่ถูกต้อง',
                (summary['invalid'] + summary['invalidFormat']).toString(),
                Colors.red,
              ), // 'Invalid' in Thai
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
