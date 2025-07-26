import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../view_models/subnet_calculator_view_model.dart';
import '../widgets/subnet_input_form.dart';
import '../widgets/subnet_result_display.dart';
import '../widgets/ip_validation_form.dart';
import 'calculation_history_page.dart';

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
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab controller changes (including swipes)
    _tabController.addListener(_onTabChange);
    _tabController.animation?.addListener(_onTabAnimationChange);
  }

  void _onTabChange() {
    if (_viewModel != null) {
      // Support both tap and swipe changes
      if (_tabController.indexIsChanging || 
          _viewModel!.currentTab.index != _tabController.index) {
        final newTab = SubnetCalculatorTab.values[_tabController.index];
        _viewModel!.switchTab(newTab);
      }
    }
  }

  void _onTabAnimationChange() {
    if (_viewModel != null && _tabController.animation != null) {
      // Handle swipe gestures during animation
      final animationValue = _tabController.animation!.value;
      final targetIndex = animationValue.round();
      
      // Update ViewModel when user swipes past the midpoint
      if (targetIndex != _viewModel!.currentTab.index && 
          targetIndex >= 0 && targetIndex < 2) {
        final newTab = SubnetCalculatorTab.values[targetIndex];
        _viewModel!.switchTab(newTab);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.animation?.removeListener(_onTabAnimationChange);
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

          // Update TabController when ViewModel tab changes (but not during user swipe)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final targetIndex = viewModel.currentTab.index;
            if (_tabController.index != targetIndex && !_tabController.indexIsChanging) {
              _tabController.animateTo(targetIndex);
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Subnet Calculator'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'ประวัติการคำนวณ', // 'Calculation History' in Thai
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalculationHistoryPage(
                          viewModel: viewModel,
                        ),
                      ),
                    );
                  },
                ),
              ],
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
                    return const SizedBox.shrink();
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

}
