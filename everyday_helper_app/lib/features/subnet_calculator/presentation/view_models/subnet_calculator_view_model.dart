import 'package:flutter/foundation.dart';
import '../../domain/models/subnet_info.dart';
import '../../domain/models/subnet_validation_result.dart';
import '../../domain/models/subnet_calculation_history.dart';
import '../../domain/use_cases/calculate_subnet_use_case.dart';
import '../../domain/use_cases/validate_ip_in_subnet_use_case.dart';

enum SubnetCalculatorTab { calculation, validation, history }

class SubnetCalculatorViewModel extends ChangeNotifier {
  // Use cases
  final CalculateSubnetUseCase _calculateSubnetUseCase =
      CalculateSubnetUseCase();
  final ValidateIpInSubnetUseCase _validateIpInSubnetUseCase =
      ValidateIpInSubnetUseCase();

  // State management
  SubnetCalculatorTab _currentTab = SubnetCalculatorTab.calculation;
  bool _isLoading = false;
  String? _errorMessage;

  // Subnet calculation state
  String _ipAddress = '';
  String _maskOrCidr = '';
  SubnetInfo? _currentSubnetInfo;
  String? _calculationError;

  // IP validation state
  String _testIpAddress = '';
  String _networkAddress = '';
  String _networkMaskOrCidr = '';
  List<SubnetValidationResult> _validationResults = [];
  String? _validationError;

  // History
  final SubnetCalculationHistory _history = SubnetCalculationHistory();

  // Getters
  SubnetCalculatorTab get currentTab => _currentTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  // Subnet calculation getters
  String get ipAddress => _ipAddress;
  String get maskOrCidr => _maskOrCidr;
  SubnetInfo? get currentSubnetInfo => _currentSubnetInfo;
  String? get calculationError => _calculationError;
  bool get hasCalculationError =>
      _calculationError != null && _calculationError!.isNotEmpty;
  bool get hasSubnetResult => _currentSubnetInfo != null;

  // IP validation getters
  String get testIpAddress => _testIpAddress;
  String get networkAddress => _networkAddress;
  String get networkMaskOrCidr => _networkMaskOrCidr;
  List<SubnetValidationResult> get validationResults =>
      List.unmodifiable(_validationResults);
  String? get validationError => _validationError;
  bool get hasValidationError =>
      _validationError != null && _validationError!.isNotEmpty;
  bool get hasValidationResults => _validationResults.isNotEmpty;

  // History getters
  List<SubnetCalculationEntry> get historyEntries => _history.entries;
  List<SubnetCalculationEntry> get recentCalculations =>
      _history.getRecent(limit: 10);
  List<SubnetCalculationEntry> get todayCalculations => _history.getToday();
  bool get hasHistory => _history.isNotEmpty;
  int get historyCount => _history.length;

  // Tab management
  void switchTab(SubnetCalculatorTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      _clearError();
      notifyListeners();
    }
  }

  // Subnet calculation methods
  void updateIpAddress(String value) {
    if (_ipAddress != value) {
      _ipAddress = value;
      _clearCalculationError();
      notifyListeners();
    }
  }

  void updateMaskOrCidr(String value) {
    if (_maskOrCidr != value) {
      _maskOrCidr = value;
      _clearCalculationError();
      notifyListeners();
    }
  }

  void clearCalculationInputs() {
    _ipAddress = '';
    _maskOrCidr = '';
    _currentSubnetInfo = null;
    _clearCalculationError();
    notifyListeners();
  }

  Future<void> calculateSubnet() async {
    _clearCalculationError();
    _setLoading(true);

    try {
      // Validate input
      final validationError = _calculateSubnetUseCase.validateCalculationInput(
        _ipAddress,
        _maskOrCidr.isEmpty ? null : _maskOrCidr,
      );

      if (validationError != null) {
        _setCalculationError(validationError);
        return;
      }

      // Perform calculation
      final subnetInfo = _calculateSubnetUseCase.calculateFromMixedInput(
        _ipAddress,
        _maskOrCidr.isEmpty ? null : _maskOrCidr,
      );

      _currentSubnetInfo = subnetInfo;

      // Add to history
      _history.addSubnetCalculation(subnetInfo);
    } catch (e) {
      _setCalculationError(
        'เกิดข้อผิดพลาดในการคำนวณ: ${e.toString()}',
      ); // 'Error in calculation' in Thai
    } finally {
      _setLoading(false);
    }
  }

  void useHistoryCalculation(SubnetCalculationEntry entry) {
    if (entry.type == SubnetCalculationType.subnetCalculation) {
      try {
        final subnetInfo = SubnetInfo.fromMap(entry.data);
        _ipAddress = subnetInfo.inputIpAddress;
        _maskOrCidr = subnetInfo.prefixLength.toString();
        _currentSubnetInfo = subnetInfo;
        _clearCalculationError();
        switchTab(SubnetCalculatorTab.calculation);
        notifyListeners();
      } catch (e) {
        _setError(
          'ไม่สามารถโหลดข้อมูลจากประวัติได้: ${e.toString()}',
        ); // 'Cannot load data from history' in Thai
      }
    }
  }

  // IP validation methods
  void updateTestIpAddress(String value) {
    if (_testIpAddress != value) {
      _testIpAddress = value;
      _clearValidationError();
      notifyListeners();
    }
  }

  void updateNetworkAddress(String value) {
    if (_networkAddress != value) {
      _networkAddress = value;
      _clearValidationError();
      notifyListeners();
    }
  }

  void updateNetworkMaskOrCidr(String value) {
    if (_networkMaskOrCidr != value) {
      _networkMaskOrCidr = value;
      _clearValidationError();
      notifyListeners();
    }
  }

  void clearValidationInputs() {
    _testIpAddress = '';
    _networkAddress = '';
    _networkMaskOrCidr = '';
    _validationResults.clear();
    _clearValidationError();
    notifyListeners();
  }

  Future<void> validateSingleIP() async {
    _clearValidationError();
    _setLoading(true);

    try {
      // Validate input
      final validationError = _validateIpInSubnetUseCase
          .validateInputParameters(
            _testIpAddress,
            _networkAddress,
            _networkMaskOrCidr.isEmpty ? null : _networkMaskOrCidr,
          );

      if (validationError != null) {
        _setValidationError(validationError);
        return;
      }

      // Perform validation
      final result = _validateIpInSubnetUseCase.validateFromMixedInput(
        _testIpAddress,
        _networkAddress,
        _networkMaskOrCidr.isEmpty ? null : _networkMaskOrCidr,
      );

      _validationResults = [result];

      // Add to history
      _history.addValidationResult(result);
    } catch (e) {
      _setValidationError(
        'เกิดข้อผิดพลาดในการตรวจสอบ: ${e.toString()}',
      ); // 'Error in validation' in Thai
    } finally {
      _setLoading(false);
    }
  }

  Future<void> validateMultipleIPs(String multipleIpsText) async {
    _clearValidationError();
    _setLoading(true);

    try {
      // Validate network input
      final validationError = _validateIpInSubnetUseCase
          .validateInputParameters(
            '192.168.1.1', // Dummy IP for network validation
            _networkAddress,
            _networkMaskOrCidr.isEmpty ? null : _networkMaskOrCidr,
          );

      if (validationError != null &&
          !validationError.contains('ต้องการตรวจสอบ')) {
        _setValidationError(validationError);
        return;
      }

      // Parse network specification
      String networkIp;
      int prefixLength;

      if (_networkMaskOrCidr.isEmpty && _networkAddress.contains('/')) {
        final parts = _networkAddress.split('/');
        networkIp = parts[0].trim();
        final cidr = int.tryParse(parts[1].trim());
        if (cidr == null) {
          _setValidationError(
            'Prefix length ไม่ถูกต้อง',
          ); // 'Invalid prefix length' in Thai
          return;
        }
        prefixLength = cidr;
      } else {
        networkIp = _networkAddress;
        if (_networkMaskOrCidr.contains('.')) {
          // Subnet mask - convert to CIDR
          final result = _validateIpInSubnetUseCase.validateWithSubnetMask(
            '192.168.1.1',
            networkIp,
            _networkMaskOrCidr,
          );
          prefixLength = result.prefixLength;
        } else {
          // CIDR
          final cidr = int.tryParse(_networkMaskOrCidr);
          if (cidr == null) {
            _setValidationError('CIDR ไม่ถูกต้อง'); // 'Invalid CIDR' in Thai
            return;
          }
          prefixLength = cidr;
        }
      }

      // Perform multiple IP validation
      final results = _validateIpInSubnetUseCase.validateFromTextInput(
        multipleIpsText,
        networkIp,
        prefixLength,
      );

      if (results.isEmpty) {
        _setValidationError(
          'ไม่พบ IP Address ที่ถูกต้อง',
        ); // 'No valid IP addresses found' in Thai
        return;
      }

      _validationResults = results;

      // Add results to history
      for (final result in results) {
        _history.addValidationResult(result);
      }
    } catch (e) {
      _setValidationError(
        'เกิดข้อผิดพลาดในการตรวจสอบ: ${e.toString()}',
      ); // 'Error in validation' in Thai
    } finally {
      _setLoading(false);
    }
  }

  void useHistoryValidation(SubnetCalculationEntry entry) {
    if (entry.type == SubnetCalculationType.ipValidation) {
      try {
        final result = SubnetValidationResult.fromMap(entry.data);
        _testIpAddress = result.testIpAddress;
        _networkAddress = result.networkAddress;
        _networkMaskOrCidr = result.prefixLength.toString();
        _validationResults = [result];
        _clearValidationError();
        switchTab(SubnetCalculatorTab.validation);
        notifyListeners();
      } catch (e) {
        _setError(
          'ไม่สามารถโหลดข้อมูลจากประวัติได้: ${e.toString()}',
        ); // 'Cannot load data from history' in Thai
      }
    }
  }

  // History management
  void clearHistory() {
    _history.clearHistory();
    notifyListeners();
  }

  void removeHistoryEntry(String id) {
    _history.removeEntry(id);
    notifyListeners();
  }

  Map<String, dynamic> getHistorySummary() {
    final total = _history.length;
    final calculations = _history
        .getByType(SubnetCalculationType.subnetCalculation)
        .length;
    final validations = _history
        .getByType(SubnetCalculationType.ipValidation)
        .length;

    return {
      'total': total,
      'calculations': calculations,
      'validations': validations,
      'today': _history.getToday().length,
    };
  }

  // Utility methods
  String getSubnetSummary() {
    if (_currentSubnetInfo == null) return '';
    return _calculateSubnetUseCase.getCalculationSummary(_currentSubnetInfo!);
  }

  Map<String, dynamic> getValidationSummary() {
    return _validateIpInSubnetUseCase.getValidationSummary(_validationResults);
  }

  String formatValidationResults() {
    if (_validationResults.isEmpty) return '';

    final summary = getValidationSummary();
    final total = summary['total'] as int;
    final valid = summary['valid'] as int;

    return 'ตรวจสอบ $total IP: $valid ในเครือข่าย'; // 'Checked X IPs: Y in network' in Thai
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setCalculationError(String message) {
    _calculationError = message;
    notifyListeners();
  }

  void _clearCalculationError() {
    if (_calculationError != null) {
      _calculationError = null;
      notifyListeners();
    }
  }

  void _setValidationError(String message) {
    _validationError = message;
    notifyListeners();
  }

  void _clearValidationError() {
    if (_validationError != null) {
      _validationError = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
