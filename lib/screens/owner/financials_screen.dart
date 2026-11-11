import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/rental.dart';

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({super.key});

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _selectPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _selectNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    // Filter rentals for selected month and year
    final monthlyRentals = provider.rentals.where((r) {
      return r.creationDate.year == _selectedMonth.year && r.creationDate.month == _selectedMonth.month;
    }).toList();

    double monthlyRentalRevenue = 0.0;
    double monthlyExtensionCharges = 0.0;
    double monthlyAdditionalCharges = 0.0;
    double monthlyCollectedPayments = 0.0;
    double monthlyOutstandingBalance = 0.0;
    double monthlySecurityDepositsHeld = 0.0;

    for (var r in monthlyRentals) {
      monthlyCollectedPayments += r.advancePayment;
      monthlyOutstandingBalance += r.remainingBalance;
      monthlyAdditionalCharges += (r.additionalCharges + r.lateCharges + r.damageCharges);

      double extSum = 0.0;
      for (var ext in r.extensions) {
        extSum += ext.extensionCharges;
      }
      monthlyExtensionCharges += extSum;
      monthlyRentalRevenue += (r.totalRentalCharges - extSum - r.additionalCharges - r.lateCharges - r.damageCharges);

      if (r.status == RentalStatus.active || r.status == RentalStatus.extended) {
        monthlySecurityDepositsHeld += r.securityDeposit;
      }
    }

    double totalMonthlyRevenue = monthlyRentalRevenue + monthlyExtensionCharges + monthlyAdditionalCharges;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Financial Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Bar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: _selectPreviousMonth,
                      tooltip: 'Previous Month',
                    ),
                    Expanded(
                      child: Text(
                        monthName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: _selectNextMonth,
                      tooltip: 'Next Month',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Summary Card
            const Text('Monthly Revenue Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Colors.teal.shade50,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildReportRow('Base Rental Revenue:', 'PKR ${monthlyRentalRevenue.toStringAsFixed(0)}'),
                    _buildReportRow('Extension Charges:', 'PKR ${monthlyExtensionCharges.toStringAsFixed(0)}'),
                    _buildReportRow('Additional/Late Charges:', 'PKR ${monthlyAdditionalCharges.toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _buildReportRow('Total Monthly Revenue:', 'PKR ${totalMonthlyRevenue.toStringAsFixed(0)}', isBold: true, color: Colors.teal.shade800),
                    const Divider(height: 20),
                    _buildReportRow('Total Collected Payments:', 'PKR ${monthlyCollectedPayments.toStringAsFixed(0)}', color: Colors.green.shade800),
                    _buildReportRow('Total Outstanding Balances:', 'PKR ${monthlyOutstandingBalance.toStringAsFixed(0)}', color: Colors.red.shade800),
                    const Divider(height: 20),
                    _buildReportRow('Security Deposits Held (Refundable):', 'PKR ${monthlySecurityDepositsHeld.toStringAsFixed(0)}', color: Colors.blue.shade800),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Monthly Visual Revenue Chart Representation
            const Text('Monthly Revenue Bar Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBarRow('Base Rentals', monthlyRentalRevenue, totalMonthlyRevenue == 0 ? 1 : totalMonthlyRevenue, Colors.blue),
                    const SizedBox(height: 10),
                    _buildBarRow('Extensions', monthlyExtensionCharges, totalMonthlyRevenue == 0 ? 1 : totalMonthlyRevenue, Colors.purple),
                    const SizedBox(height: 10),
                    _buildBarRow('Additional', monthlyAdditionalCharges, totalMonthlyRevenue == 0 ? 1 : totalMonthlyRevenue, Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detailed Monthly Transactions List
            Text('Monthly Transactions ($monthName)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            monthlyRentals.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No rental transactions recorded for this month.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthlyRentals.length,
                    itemBuilder: (context, index) {
                      final r = monthlyRentals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.receipt_long, color: Colors.teal),
                          title: Text('${r.customerName} (${r.rentalId})', maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${r.vehicleName} • Reg: ${r.vehicleRegistrationNumber}\nPaid: PKR ${r.advancePayment.toStringAsFixed(0)} | Balance: PKR ${r.remainingBalance.toStringAsFixed(0)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('PKR ${r.totalRentalCharges.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String title, String val, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarRow(String label, double amount, double total, Color color) {
    double ratio = (amount / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Flexible(child: Text('PKR ${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
