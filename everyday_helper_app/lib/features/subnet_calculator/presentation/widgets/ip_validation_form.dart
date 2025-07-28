import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/models/subnet_validation_result.dart';
import '../view_models/subnet_calculator_view_model.dart';

// Input formatters for different field types
class IpAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only numbers, dots, and slashes for IP addresses with optional CIDR
    String filteredString = newValue.text.replaceAll(RegExp(r'[^0-9./]'), '');

    // Prevent consecutive dots
    filteredString = filteredString.replaceAll(RegExp(r'\.{2,}'), '.');

    // Prevent starting with dot
    if (filteredString.startsWith('.')) {
      filteredString = filteredString.substring(1);
    }

    // Validate IPv4 format and constraints
    if (filteredString.length > oldValue.text.length) {
      // Only format if we're adding characters (not deleting)
      final parts = filteredString.split('.');

      // Limit to maximum 4 octets
      if (parts.length > 4) {
        return oldValue;
      }

      String formattedText = '';
      for (int i = 0; i < parts.length; i++) {
        String part = parts[i];

        if (part.contains('/')) {
          // Handle CIDR notation
          final cidrParts = part.split('/');
          String octet = cidrParts[0];

          // Validate octet (0-255)
          if (octet.isNotEmpty) {
            if (octet.length > 3) {
              octet = octet.substring(0, 3);
            }

            final octetValue = int.tryParse(octet);
            if (octetValue != null && octetValue > 255) {
              // If value exceeds 255, truncate to valid range
              octet = '255';
            }
          }

          // Validate CIDR (0-32)
          if (cidrParts.length > 1 && cidrParts[1].isNotEmpty) {
            final cidrValue = int.tryParse(cidrParts[1]);
            if (cidrValue != null && cidrValue > 32) {
              cidrParts[1] = '32';
            }
          }

          formattedText += '$octet/${cidrParts.length > 1 ? cidrParts[1] : ''}';
        } else {
          // Regular IP octet
          if (part.length > 3) {
            // Move extra digits to next part only if not at last part and under 4 parts
            if (i < 3 && parts.length < 4) {
              final remainingDigits = part.substring(3);
              part = part.substring(0, 3);

              // Validate current octet
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }

              formattedText +=
                  '$part.${remainingDigits.length > 3 ? remainingDigits.substring(0, 3) : remainingDigits}';
            } else {
              // Last part or max parts reached: just truncate to 3 digits
              part = part.substring(0, 3);

              // Validate octet
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }

              formattedText += part;
            }
          } else {
            // Validate octet if complete (3 digits or user stops typing)
            if (part.isNotEmpty) {
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }
            }

            if (part.length == 3 &&
                i < 3 &&
                !oldValue.text.endsWith('.') &&
                parts.length < 4) {
              // Auto-add dot after 3 digits
              formattedText += '$part.';
            } else {
              formattedText += part;
              if (i < parts.length - 1) {
                formattedText += '.';
              }
            }
          }
        }
      }
      filteredString = formattedText;
    }

    return TextEditingValue(
      text: filteredString,
      selection: TextSelection.collapsed(offset: filteredString.length),
    );
  }
}

class SubnetMaskInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only numbers and dots for subnet masks and CIDR numbers
    String filteredString = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Prevent consecutive dots
    filteredString = filteredString.replaceAll(RegExp(r'\.{2,}'), '.');

    // Prevent starting with dot
    if (filteredString.startsWith('.')) {
      filteredString = filteredString.substring(1);
    }

    // Auto-insert dots after every 3 digits for subnet mask formatting
    if (filteredString.length > oldValue.text.length) {
      // Only format if we're adding characters (not deleting)
      if (filteredString.contains('.')) {
        // Already has dots - treat as subnet mask
        final parts = filteredString.split('.');

        // Limit to maximum 4 octets for subnet mask
        if (parts.length > 4) {
          return oldValue;
        }

        String formattedText = '';
        for (int i = 0; i < parts.length; i++) {
          String part = parts[i];

          // Limit each subnet mask part to maximum 3 digits and validate range
          if (part.length > 3) {
            if (i < 3 && parts.length < 4) {
              // Move extra digits to next part
              final remainingDigits = part.substring(3);
              part = part.substring(0, 3);

              // Validate octet (0-255)
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }

              formattedText +=
                  '$part.${remainingDigits.length > 3 ? remainingDigits.substring(0, 3) : remainingDigits}';
            } else {
              // Last part or max parts: truncate to 3 digits
              part = part.substring(0, 3);

              // Validate octet (0-255)
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }

              formattedText += part;
            }
          } else {
            // Validate octet if not empty
            if (part.isNotEmpty) {
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }
            }

            if (part.length == 3 &&
                i < 3 &&
                !oldValue.text.endsWith('.') &&
                parts.length < 4) {
              // Auto-add dot after 3 digits
              formattedText += '$part.';
            } else {
              formattedText += part;
              if (i < parts.length - 1) {
                formattedText += '.';
              }
            }
          }
        }
        filteredString = formattedText;
      } else {
        // No dots yet - could be subnet mask being typed or CIDR
        // For CIDR, validate range 0-32
        if (filteredString.length <= 2) {
          // Could be CIDR (0-32)
          final cidrValue = int.tryParse(filteredString);
          if (cidrValue != null && cidrValue > 32) {
            filteredString = '32';
          }
        } else if (filteredString.length == 3 && !oldValue.text.endsWith('.')) {
          // Could be start of subnet mask - validate first octet
          final octetValue = int.tryParse(filteredString);
          if (octetValue != null && octetValue <= 255) {
            // Auto-add dot after 3 digits (subnet mask format)
            filteredString = '$filteredString.';
          } else {
            // Invalid octet value, cap at 255
            filteredString = '255.';
          }
        } else if (filteredString.length > 3) {
          // More than 3 digits without dots - format as subnet mask
          String formattedText = '';
          for (int i = 0; i < filteredString.length; i += 3) {
            if (i > 0) formattedText += '.';
            final endIndex = (i + 3 < filteredString.length)
                ? i + 3
                : filteredString.length;
            String part = filteredString.substring(i, endIndex);

            // Validate each octet
            if (part.isNotEmpty) {
              final octetValue = int.tryParse(part);
              if (octetValue != null && octetValue > 255) {
                part = '255';
              }
            }

            formattedText += part;
          }
          filteredString = formattedText;
        }
      }
    }

    return TextEditingValue(
      text: filteredString,
      selection: TextSelection.collapsed(offset: filteredString.length),
    );
  }
}

class MultipleIpsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow numbers, dots, commas, spaces, and newlines for multiple IPs
    final filteredString = newValue.text.replaceAll(RegExp(r'[^0-9., \n]'), '');

    return TextEditingValue(
      text: filteredString,
      selection: TextSelection.collapsed(offset: filteredString.length),
    );
  }
}

class IpValidationForm extends StatefulWidget {
  const IpValidationForm({super.key});

  @override
  State<IpValidationForm> createState() => _IpValidationFormState();
}

class _IpValidationFormState extends State<IpValidationForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _multipleIpsController = TextEditingController();
  final TextEditingController _networkAddressController =
      TextEditingController();
  final TextEditingController _networkMaskController = TextEditingController();
  final TextEditingController _testIpController = TextEditingController();
  final FocusNode _networkMaskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes and update ViewModel
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final viewModel = context.read<SubnetCalculatorViewModel>();
        viewModel.updateValidationTabIndex(_tabController.index);
      }
    });
  }

  void _initializeControllers(SubnetCalculatorViewModel viewModel) {
    // Initialize controllers with current ViewModel values
    if (_networkAddressController.text != viewModel.networkAddress) {
      _networkAddressController.text = viewModel.networkAddress;
    }
    if (_networkMaskController.text != viewModel.networkMaskOrCidr) {
      _networkMaskController.text = viewModel.networkMaskOrCidr;
    }
    if (_testIpController.text != viewModel.testIpAddress) {
      _testIpController.text = viewModel.testIpAddress;
    }
  }

  void _handleNetworkAddressInput(
    String value,
    SubnetCalculatorViewModel viewModel,
  ) {
    // Check if user typed '/' to auto-focus network mask field
    if (value.endsWith('/')) {
      // Remove the '/' from network address field
      final addressWithoutSlash = value.substring(0, value.length - 1);
      _networkAddressController.text = addressWithoutSlash;
      _networkAddressController.selection = TextSelection.fromPosition(
        TextPosition(offset: addressWithoutSlash.length),
      );

      // Update ViewModel with network address without slash
      viewModel.updateNetworkAddress(addressWithoutSlash);

      // Focus on network mask field
      _networkMaskFocusNode.requestFocus();
      return;
    }

    // Normal update
    viewModel.updateNetworkAddress(value);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _multipleIpsController.dispose();
    _networkAddressController.dispose();
    _networkMaskController.dispose();
    _testIpController.dispose();
    _networkMaskFocusNode.dispose();
    super.dispose();
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
          controller: _networkAddressController,
          inputFormatters: [
            IpAddressInputFormatter(),
            LengthLimitingTextInputFormatter(18), // Max length for IP with CIDR
          ],
          decoration: InputDecoration(
            labelText: 'Network Address',
            hintText:
                '192.168.1.0 หรือ 192.168.1.0/24', // 'or 192.168.1.0/24' in Thai
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.router),
            helperText:
                'ใส่ Network Address ของเครือข่ายที่ต้องการตรวจสอบ', // 'Enter network address to validate against' in Thai
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          ),
          onChanged: (value) {
            _handleNetworkAddressInput(value, viewModel);
          },
        ),
        const SizedBox(height: 16),

        // Subnet Mask or CIDR input
        TextFormField(
          controller: _networkMaskController,
          focusNode: _networkMaskFocusNode,
          inputFormatters: [
            SubnetMaskInputFormatter(),
            LengthLimitingTextInputFormatter(15), // Max length for subnet mask
          ],
          decoration: InputDecoration(
            labelText: 'Subnet Mask หรือ CIDR', // 'Subnet Mask or CIDR' in Thai
            hintText: '255.255.255.0 หรือ 24', // 'or 24' in Thai
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.network_check),
            helperText:
                'ใส่ Subnet Mask หรือ CIDR ของเครือข่าย', // 'Enter subnet mask or CIDR of the network' in Thai
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          ),
          onChanged: (value) {
            viewModel.updateNetworkMaskOrCidr(value);
          },
        ),
      ],
    );
  }

  Widget _buildSingleIpTab(SubnetCalculatorViewModel viewModel) {
    return Column(
      children: [
        // Single IP input
        TextFormField(
          controller: _testIpController,
          inputFormatters: [
            IpAddressInputFormatter(),
            LengthLimitingTextInputFormatter(15), // Max length for single IP
          ],
          decoration: InputDecoration(
            labelText:
                'IP Address ที่ต้องการตรวจสอบ', // 'IP Address to validate' in Thai
            hintText: '192.168.1.100',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.computer),
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          ),
          onChanged: (value) {
            viewModel.updateTestIpAddress(value);
          },
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
            IconButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      _networkAddressController.clear();
                      _networkMaskController.clear();
                      _testIpController.clear();
                      viewModel.clearValidationInputs();
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
            inputFormatters: [
              MultipleIpsInputFormatter(),
              LengthLimitingTextInputFormatter(
                500,
              ), // Max length for multiple IPs
            ],
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
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            maxLines: 4,
            onChanged: (value) {
              // Update ViewModel with multiple IPs text for FAB access
              final viewModel = context.read<SubnetCalculatorViewModel>();
              viewModel.updateMultipleIpsText(value);
            },
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
            IconButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      _networkAddressController.clear();
                      _networkMaskController.clear();
                      _multipleIpsController.clear();
                      viewModel.clearValidationInputs();
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
