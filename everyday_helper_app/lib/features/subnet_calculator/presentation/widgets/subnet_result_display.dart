import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/models/subnet_info.dart';
import '../view_models/subnet_calculator_view_model.dart';

class SubnetResultDisplay extends StatelessWidget {
  const SubnetResultDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubnetCalculatorViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.hasSubnetResult) {
          return _buildEmptyState(context);
        }

        final subnetInfo = viewModel.currentSubnetInfo!;

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
                      Icons.network_check,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ผลการคำนวณ Subnet', // 'Subnet Calculation Result' in Thai
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyAllResults(context, subnetInfo),
                      icon: const Icon(Icons.copy),
                      tooltip:
                          'คัดลอกผลลัพธ์ทั้งหมด', // 'Copy all results' in Thai
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input summary
                _buildSummaryCard(
                  context,
                  'ข้อมูลนำเข้า', // 'Input Data' in Thai
                  Icons.input,
                  [
                    _buildInfoRow('IP Address:', subnetInfo.inputIpAddress),
                    _buildInfoRow('CIDR:', '/${subnetInfo.prefixLength}'),
                    _buildInfoRow('Subnet Mask:', subnetInfo.subnetMask),
                    _buildInfoRow('Network Class:', subnetInfo.subnetClass),
                  ],
                ),

                const SizedBox(height: 12),

                // Network information
                _buildSummaryCard(
                  context,
                  'ข้อมูลเครือข่าย', // 'Network Information' in Thai
                  Icons.router,
                  [
                    _buildInfoRow(
                      'Network Address:',
                      subnetInfo.networkAddress,
                      copyable: true,
                    ),
                    _buildInfoRow(
                      'Broadcast Address:',
                      subnetInfo.broadcastAddress,
                      copyable: true,
                    ),
                    _buildInfoRow('Network Range:', subnetInfo.networkRange),
                  ],
                ),

                const SizedBox(height: 12),

                // Host information
                _buildSummaryCard(
                  context,
                  'ข้อมูลโฮสต์', // 'Host Information' in Thai
                  Icons.devices,
                  [
                    _buildInfoRow('Total Hosts:', '${subnetInfo.totalHosts}'),
                    _buildInfoRow(
                      'Usable Hosts:',
                      '${subnetInfo.usableHosts}',
                      highlight: subnetInfo.hasUsableHosts,
                    ),
                    _buildInfoRow(
                      'First Usable:',
                      subnetInfo.firstUsableHost,
                      copyable: true,
                    ),
                    _buildInfoRow(
                      'Last Usable:',
                      subnetInfo.lastUsableHost,
                      copyable: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Binary representation (optional detailed view)
                if (subnetInfo.prefixLength < 32) ...[
                  ExpansionTile(
                    leading: Icon(
                      Icons.code,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text(
                      'รายละเอียดเพิ่มเติม',
                    ), // 'Additional Details' in Thai
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Timestamp:',
                              subnetInfo.formattedTimestamp,
                            ),
                            _buildInfoRow(
                              'Total Network Bits:',
                              '${subnetInfo.prefixLength}',
                            ),
                            _buildInfoRow(
                              'Total Host Bits:',
                              '${32 - subnetInfo.prefixLength}',
                            ),
                            _buildInfoRow(
                              'Subnet Efficiency:',
                              '${((subnetInfo.usableHosts / subnetInfo.totalHosts) * 100).toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.network_check, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีผลการคำนวณ', // 'No calculation results yet' in Thai
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณาใส่ IP Address และ Subnet Mask หรือ CIDR แล้วกดคำนวณ', // 'Please enter IP Address and Subnet Mask or CIDR then calculate' in Thai
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool copyable = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: highlight
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: highlight ? Colors.green[700] : null,
                    ),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => _copyToClipboard(context, value),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('คัดลอก "$text" แล้ว'), // 'Copied "X"' in Thai
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyAllResults(BuildContext context, SubnetInfo subnetInfo) {
    final results =
        '''
Subnet Calculation Results
=========================
Input: ${subnetInfo.inputIpAddress}/${subnetInfo.prefixLength}
Subnet Mask: ${subnetInfo.subnetMask}
Network Class: ${subnetInfo.subnetClass}

Network Information:
- Network Address: ${subnetInfo.networkAddress}
- Broadcast Address: ${subnetInfo.broadcastAddress}
- Network Range: ${subnetInfo.networkRange}

Host Information:
- Total Hosts: ${subnetInfo.totalHosts}
- Usable Hosts: ${subnetInfo.usableHosts}
- First Usable: ${subnetInfo.firstUsableHost}
- Last Usable: ${subnetInfo.lastUsableHost}
- Usable Range: ${subnetInfo.usableRange}

Generated at: ${subnetInfo.formattedTimestamp}
''';

    Clipboard.setData(ClipboardData(text: results));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'คัดลอกผลลัพธ์ทั้งหมดแล้ว',
        ), // 'Copied all results' in Thai
        duration: Duration(seconds: 2),
      ),
    );
  }
}
