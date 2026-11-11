import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/rental.dart';
import '../common/receipt_pdf_preview_screen.dart';

class ActiveRentalsScreen extends StatelessWidget {
  const ActiveRentalsScreen({super.key});

  void _showExtendRentalDialog(BuildContext context, Rental rental) {
    int additionalDays = 1;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          double extraCharge = rental.dailyRate * additionalDays;
          DateTime newReturnDate = rental.currentReturnDate.add(Duration(days: additionalDays));

          return AlertDialog(
            title: Text('Extend Rental: ${rental.rentalId}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${rental.customerName}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Car: ${rental.vehicleName}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Current Return Date: ${rental.currentReturnDate.toLocal().toString().split(' ')[0]}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: Text('Additional Days:')),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () { if (additionalDays > 1) setState(() => additionalDays--); },
                          ),
                          Text('$additionalDays Days', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => additionalDays++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('New Return Date: ${newReturnDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text('Additional Fee: PKR ${extraCharge.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Extension Notes', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                onPressed: () {
                  final provider = Provider.of<AppProvider>(context, listen: false);
                  provider.extendRental(
                    rentalId: rental.rentalId,
                    newReturnDate: newReturnDate,
                    additionalDays: additionalDays,
                    extensionCharges: extraCharge,
                    notes: notesController.text,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rental extended successfully!')));
                },
                child: const Text('Confirm Extension'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReturnCarDialog(BuildContext context, Rental rental) {
    double lateFee = rental.isOverdue ? 5000.0 : 0.0;
    double damageFee = 0.0;
    double additionalPaid = rental.remainingBalance;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Complete Rental Return: ${rental.rentalId}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Car: ${rental.vehicleName} (${rental.vehicleRegistrationNumber})', maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('Customer: ${rental.customerName}'),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: lateFee.toStringAsFixed(0)),
                    decoration: const InputDecoration(labelText: 'Late Return Fee (PKR)', border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => lateFee = double.tryParse(val) ?? 0.0),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: damageFee.toStringAsFixed(0)),
                    decoration: const InputDecoration(labelText: 'Vehicle Damage Charges (PKR)', border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => damageFee = double.tryParse(val) ?? 0.0),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: additionalPaid.toStringAsFixed(0)),
                    decoration: const InputDecoration(labelText: 'Final Payment Collected Now (PKR)', border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => additionalPaid = double.tryParse(val) ?? 0.0),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () {
                  final provider = Provider.of<AppProvider>(context, listen: false);
                  provider.completeRentalReturn(
                    rentalId: rental.rentalId,
                    actualReturnDate: DateTime.now(),
                    lateFee: lateFee,
                    damageFee: damageFee,
                    additionalPaid: additionalPaid,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle returned and marked Available!')));
                },
                child: const Text('Process Return'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final rentalsList = provider.rentals;

    return Scaffold(
      appBar: AppBar(title: const Text('Active & Historical Rentals')),
      body: rentalsList.isEmpty
          ? const Center(child: Text('No rental records found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rentalsList.length,
              itemBuilder: (context, index) {
                final r = rentalsList[index];
                Color statusColor = Colors.blue;
                if (r.isOverdue) statusColor = Colors.red;
                if (r.status == RentalStatus.completed) statusColor = Colors.green;
                if (r.status == RentalStatus.extended) statusColor = Colors.purple;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                r.rentalId,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(r.isOverdue ? 'OVERDUE' : r.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              backgroundColor: statusColor,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${r.vehicleName} (${r.vehicleRegistrationNumber})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('Customer: ${r.customerName} (CNIC: ${r.customerCnic})'),
                        Text('Return Date: ${r.currentReturnDate.toLocal().toString().split(' ')[0]}'),
                        Text('Total Charges: PKR ${r.totalRentalCharges.toStringAsFixed(0)} | Deposit: PKR ${r.securityDeposit.toStringAsFixed(0)}'),
                        Text('Advance Paid: PKR ${r.advancePayment.toStringAsFixed(0)} | Balance: PKR ${r.remainingBalance.toStringAsFixed(0)}'),
                        if (r.cnicFrontPath != null || r.cnicBackPath != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.badge, size: 16, color: Colors.blueAccent),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text('CNIC Images Uploaded', style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                        if (r.extensions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Extensions History: ${r.extensions.length} extension(s) logged.', style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                        const SizedBox(height: 12),
                        // Wrap layout to prevent ANY horizontal overflow on small screens!
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            if (r.status == RentalStatus.active || r.status == RentalStatus.extended) ...[
                              ElevatedButton.icon(
                                icon: const Icon(Icons.update, size: 16),
                                label: const Text('Extend Rental'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                                onPressed: () => _showExtendRentalDialog(context, r),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('Return Car'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                onPressed: () => _showReturnCarDialog(context, r),
                              ),
                            ],
                            OutlinedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf, size: 16),
                              label: const Text('Receipt'),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptPdfPreviewScreen(rental: r)));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
