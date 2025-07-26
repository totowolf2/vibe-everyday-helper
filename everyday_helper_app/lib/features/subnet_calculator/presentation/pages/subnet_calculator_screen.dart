import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../view_models/subnet_calculator_view_model.dart';
import '../widgets/subnet_input_form.dart';
import '../widgets/subnet_result_display.dart';
import '../widgets/ip_validation_form.dart';
import '../widgets/calculation_history_list.dart';

class SubnetCalculatorScreen extends StatefulWidget {
  const SubnetCalculatorScreen({super.key});

  @override
  State<SubnetCalculatorScreen> createState() => _SubnetCalculatorScreenState();
}

class _SubnetCalculatorScreenState extends State<SubnetCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SubnetCalculatorViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listen to tab controller changes (including swipes)
    _tabController.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (_viewModel != null && _tabController.indexIsChanging) {
      final newTab = SubnetCalculatorTab.values[_tabController.index];
      _viewModel!.switchTab(newTab);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubnetCalculatorViewModel(),
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<SubnetCalculatorViewModel>();

          // Store reference to ViewModel for tab change listener
          _viewModel = viewModel;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Subnet Calculator'),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.calculate),
                    text: 'คำนวณ', // 'Calculate' in Thai
                  ),
                  Tab(
                    icon: Icon(Icons.verified_user),
                    text: 'ตรวจสอบ IP', // 'Validate IP' in Thai
                  ),
                  Tab(
                    icon: Icon(Icons.history),
                    text: 'ประวัติ', // 'History' in Thai
                  ),
                ],
              ),
            ),
            body: Consumer<SubnetCalculatorViewModel>(
              builder: (context, viewModel, child) {
                // Show global error if exists
                if (viewModel.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(viewModel.errorMessage!),
                        backgroundColor: Colors.red[600],
                        action: SnackBarAction(
                          label: 'ปิด', // 'Close' in Thai
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  });
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCalculationTab(),
                    _buildValidationTab(),
                    _buildHistoryTab(),
                  ],
                );
              },
            ),
            floatingActionButton: Consumer<SubnetCalculatorViewModel>(
              builder: (context, viewModel, child) {
                // Show different FAB based on current tab
                switch (viewModel.currentTab) {
                  case SubnetCalculatorTab.calculation:
                    return FloatingActionButton.extended(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              viewModel.calculateSubnet();
                            },
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.calculate),
                      label: Text(
                        viewModel.isLoading
                            ? 'กำลังคำนวณ...'
                            : 'คำนวณ Subnet', // 'Calculating...' : 'Calculate Subnet' in Thai
                      ),
                    );

                  case SubnetCalculatorTab.validation:
                    return FloatingActionButton.extended(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              // Check which validation tab is active
                              if (viewModel.validationTabIndex == 0) {
                                // Single IP tab
                                viewModel.validateSingleIP();
                              } else {
                                // Multiple IPs tab - trigger multiple IP validation
                                viewModel.validateMultipleIPsFromFAB();
                              }
                            },
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              viewModel.validationTabIndex == 0
                                  ? Icons.verified_user
                                  : Icons.playlist_add_check,
                            ),
                      label: Text(
                        viewModel.isLoading
                            ? 'กำลังตรวจสอบ...'
                            : viewModel.validationTabIndex == 0
                            ? 'ตรวจสอบ IP' // 'Validate IP' in Thai
                            : 'ตรวจสอบหลาย IP', // 'Validate Multiple IPs' in Thai
                      ),
                    );

                  case SubnetCalculatorTab.history:
                    if (viewModel.hasHistory) {
                      return FloatingActionButton.extended(
                        onPressed: () =>
                            _showClearHistoryDialog(context, viewModel),
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text(
                          'ล้างประวัติ',
                        ), // 'Clear History' in Thai
                        backgroundColor: Colors.red[600],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalculationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          const SubnetInputForm(),
          const SizedBox(height: 16),
          const SubnetResultDisplay(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          IpValidationForm(),
          SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: CalculationHistoryList(),
    );
  }

  void _showClearHistoryDialog(
    BuildContext context,
    SubnetCalculatorViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างประวัติทั้งหมด'), // 'Clear All History' in Thai
        content: const Text(
          'คุณต้องการล้างประวัติการคำนวณทั้งหมดหรือไม่?\n\nการดำเนินการนี้ไม่สามารถยกเลิกได้', // 'Do you want to clear all calculation history? This action cannot be undone' in Thai
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'), // 'Cancel' in Thai
          ),
          TextButton(
            onPressed: () {
              viewModel.clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'ล้างประวัติทั้งหมดแล้ว',
                  ), // 'All history cleared' in Thai
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ล้างทั้งหมด'), // 'Clear All' in Thai
          ),
        ],
      ),
    );
  }
}
