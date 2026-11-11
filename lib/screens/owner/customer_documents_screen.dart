import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class CustomerDocumentsScreen extends StatefulWidget {
  const CustomerDocumentsScreen({super.key});

  @override
  State<CustomerDocumentsScreen> createState() => _CustomerDocumentsScreenState();
}

class _CustomerDocumentsScreenState extends State<CustomerDocumentsScreen> {
  String _searchQuery = '';

  void _showImageDialog(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => Column(
                  children: const [
                    Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Image file not found on local storage'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final results = provider.searchCustomers(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Documents & Profiles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
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
                ? const Center(child: Text('No customer profiles found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final c = results[index];
                      final customerRentals = provider.rentals
                          .where((r) => r.customerId == c.id || r.customerCnic.replaceAll('-', '') == c.cnicNumber.replaceAll('-', ''))
                          .toList();

                      // Collect images from customer profile & rental history
                      List<Map<String, String>> images = [];
                      if (c.cnicFrontPath != null && c.cnicFrontPath!.isNotEmpty) {
                        images.add({'title': 'CNIC Front', 'path': c.cnicFrontPath!});
                      }
                      if (c.cnicBackPath != null && c.cnicBackPath!.isNotEmpty) {
                        images.add({'title': 'CNIC Back', 'path': c.cnicBackPath!});
                      }
                      if (c.selfiePath != null && c.selfiePath!.isNotEmpty) {
                        images.add({'title': 'Live Selfie', 'path': c.selfiePath!});
                      }

                      for (var r in customerRentals) {
                        if (r.cnicFrontPath != null && r.cnicFrontPath!.isNotEmpty && !images.any((img) => img['path'] == r.cnicFrontPath)) {
                          images.add({'title': 'CNIC Front (${r.rentalId})', 'path': r.cnicFrontPath!});
                        }
                        if (r.cnicBackPath != null && r.cnicBackPath!.isNotEmpty && !images.any((img) => img['path'] == r.cnicBackPath)) {
                          images.add({'title': 'CNIC Back (${r.rentalId})', 'path': r.cnicBackPath!});
                        }
                        if (r.selfiePath != null && r.selfiePath!.isNotEmpty && !images.any((img) => img['path'] == r.selfiePath)) {
                          images.add({'title': 'Live Selfie (${r.rentalId})', 'path': r.selfiePath!});
                        }
                        if (r.signatureImagePath != null && r.signatureImagePath!.isNotEmpty && !images.any((img) => img['path'] == r.signatureImagePath)) {
                          images.add({'title': 'Signature (${r.rentalId})', 'path': r.signatureImagePath!});
                        }
                        if (r.thumbImpressionPath != null && r.thumbImpressionPath!.isNotEmpty && !images.any((img) => img['path'] == r.thumbImpressionPath)) {
                          images.add({'title': 'Thumb Impression (${r.rentalId})', 'path': r.thumbImpressionPath!});
                        }
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('CNIC: ${c.cnicNumber} • Phone: ${c.mobileNumber}', maxLines: 1, overflow: TextOverflow.ellipsis),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('A-to-Z Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent)),
                                  const SizedBox(height: 8),
                                  Text('Full Name: ${c.fullName}'),
                                  Text('Father Name: ${c.fatherName}'),
                                  Text('CNIC Number: ${c.cnicNumber}'),
                                  Text('Mobile Number: ${c.mobileNumber}'),
                                  Text('Address: ${c.residentialAddress}, ${c.city}'),
                                  Text('Emergency Phone: ${c.emergencyContactNumber}'),
                                  Text('Driving Licence: ${c.drivingLicenceNumber ?? "Not Provided (Optional)"}'),
                                  Text('Registration Date: ${c.registrationDate.toLocal().toString().split(' ')[0]}'),
                                  const SizedBox(height: 16),

                                  const Text('Uploaded Verification Documents & Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent)),
                                  const SizedBox(height: 8),
                                  images.isEmpty
                                      ? const Text('No document images uploaded yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                                      : Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: images.map((img) {
                                            return InkWell(
                                              onTap: () => _showImageDialog(context, img['path']!, img['title']!),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.file(
                                                      File(img['path']!),
                                                      width: 85,
                                                      height: 85,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => Container(
                                                        width: 85,
                                                        height: 85,
                                                        color: Colors.grey.shade200,
                                                        child: const Icon(Icons.badge, color: Colors.blueAccent),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  SizedBox(
                                                    width: 85,
                                                    child: Text(
                                                      img['title']!,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                  const SizedBox(height: 16),

                                  const Text('Rental Agreement History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent)),
                                  const SizedBox(height: 8),
                                  customerRentals.isEmpty
                                      ? const Text('No rental history logged.')
                                      : Column(
                                          children: customerRentals.map((r) {
                                            return Card(
                                              color: Colors.grey.shade50,
                                              margin: const EdgeInsets.only(bottom: 8),
                                              child: ListTile(
                                                dense: true,
                                                title: Text('${r.vehicleName} (${r.vehicleRegistrationNumber})', maxLines: 1, overflow: TextOverflow.ellipsis),
                                                subtitle: Text('ID: ${r.rentalId} • Date: ${r.startDate.toLocal().toString().split(' ')[0]} • Paid: PKR ${r.advancePayment.toStringAsFixed(0)}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                                trailing: Chip(
                                                  label: Text(r.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                                  backgroundColor: Colors.blue,
                                                ),
                                              ),
                                            );
                                          }).toList(),
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
