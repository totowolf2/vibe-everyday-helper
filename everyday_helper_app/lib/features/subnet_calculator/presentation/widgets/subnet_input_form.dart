import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
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
              
              formattedText += '$part.${remainingDigits.length > 3 ? remainingDigits.substring(0, 3) : remainingDigits}';
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
            
            if (part.length == 3 && i < 3 && !oldValue.text.endsWith('.') && parts.length < 4) {
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
              
              formattedText += '$part.${remainingDigits.length > 3 ? remainingDigits.substring(0, 3) : remainingDigits}';
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
            
            if (part.length == 3 && i < 3 && !oldValue.text.endsWith('.') && parts.length < 4) {
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
            final endIndex = (i + 3 < filteredString.length) ? i + 3 : filteredString.length;
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

class SubnetInputForm extends StatefulWidget {
  const SubnetInputForm({super.key});

  @override
  State<SubnetInputForm> createState() => _SubnetInputFormState();
}

class _SubnetInputFormState extends State<SubnetInputForm> {
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _maskOrCidrController = TextEditingController();
  final FocusNode _cidrFocusNode = FocusNode();

  @override
  void dispose() {
    _ipAddressController.dispose();
    _maskOrCidrController.dispose();
    _cidrFocusNode.dispose();
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

  void _handleIpAddressInput(
    String value,
    SubnetCalculatorViewModel viewModel,
  ) {
    // Check if user typed '/' to auto-focus CIDR field
    if (value.endsWith('/')) {
      // Remove the '/' from IP address field
      final ipWithoutSlash = value.substring(0, value.length - 1);
      _ipAddressController.text = ipWithoutSlash;
      _ipAddressController.selection = TextSelection.fromPosition(
        TextPosition(offset: ipWithoutSlash.length),
      );

      // Update ViewModel with IP address without slash
      viewModel.updateIpAddress(ipWithoutSlash);

      // Focus on CIDR field
      _cidrFocusNode.requestFocus();
      return;
    }

    // Normal update
    viewModel.updateIpAddress(value);
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
                  inputFormatters: [
                    IpAddressInputFormatter(),
                    LengthLimitingTextInputFormatter(
                      18,
                    ), // Max length for IP with CIDR (e.g., 192.168.100.100/32)
                  ],
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
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  onChanged: (value) {
                    _handleIpAddressInput(value, viewModel);
                  },
                ),
                const SizedBox(height: 16),

                // Subnet Mask or CIDR input
                TextFormField(
                  controller: _maskOrCidrController,
                  focusNode: _cidrFocusNode,
                  inputFormatters: [
                    SubnetMaskInputFormatter(),
                    LengthLimitingTextInputFormatter(
                      15,
                    ), // Max length for subnet mask (255.255.255.255)
                  ],
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
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
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
