import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'new_rental_flow_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final results = provider.searchCustomers(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Management & Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search by Customer Name, CNIC, Phone, or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No customers found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final c = results[index];
                      final customerRentals = provider.rentals.where((r) => r.customerId == c.id || r.customerCnic.replaceAll('-', '') == c.cnicNumber.replaceAll('-', '')).toList();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('CNIC: ${c.cnicNumber} • Phone: ${c.mobileNumber}', maxLines: 1, overflow: TextOverflow.ellipsis),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Father Name: ${c.fatherName}'),
                                  Text('Address: ${c.residentialAddress}, ${c.city}'),
                                  Text('Emergency Phone: ${c.emergencyContactNumber}'),
                                  Text('Driving Licence: ${c.drivingLicenceNumber ?? "Not Provided (Optional)"}'),
                                  const SizedBox(height: 12),
                                  Text('Total Rental Records: ${customerRentals.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  if (customerRentals.isNotEmpty)
                                    Column(
                                      children: customerRentals.map((r) {
                                        return ListTile(
                                          dense: true,
                                          title: Text('${r.vehicleName} (${r.vehicleRegistrationNumber})', maxLines: 1, overflow: TextOverflow.ellipsis),
                                          subtitle: Text('ID: ${r.rentalId} • Charges: PKR ${r.totalRentalCharges.toStringAsFixed(0)} • Status: ${r.status.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.add_circle_outline),
                                      label: const Text('Create New Rental for this Customer'),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NewRentalFlowScreen(prefilledCustomer: c),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
