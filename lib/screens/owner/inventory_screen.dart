import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/vehicle.dart';
import 'add_edit_vehicle_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  Widget _buildCarImage(String path, {double size = 65}) {
    bool isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.directions_car, size: 36),
        ),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            width: size,
            height: size,
            color: Colors.grey.shade200,
            child: const Icon(Icons.directions_car, size: 36),
          ),
        );
      } else {
        return Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.directions_car, size: 36),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final vehicles = provider.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Car',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
              );
            },
          ),
        ],
      ),
      body: vehicles.isEmpty
          ? const Center(child: Text('No cars in inventory.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];
                Color statusColor = Colors.green;
                if (v.status == VehicleStatus.currentlyRented) statusColor = Colors.orange;
                if (v.status == VehicleStatus.underMaintenance) statusColor = Colors.purple;
                if (v.status == VehicleStatus.unavailable) statusColor = Colors.red;

                String firstImage = v.imageUrls.isNotEmpty ? v.imageUrls.first : '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildCarImage(firstImage, size: 65),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          v.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Chip(
                                        label: Text(v.status.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        backgroundColor: statusColor,
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${v.brand} • ${v.model} • Reg: ${v.registrationNumber}',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'PKR ${v.dailyPrice.toStringAsFixed(0)}/day | Deposit: PKR ${v.securityDeposit.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blueAccent),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (v.imageUrls.length > 1)
                                    Text(
                                      '📷 ${v.imageUrls.length} photos uploaded',
                                      style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit / Manage Photos'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditVehicleScreen(vehicleToEdit: v),
                                  ),
                                );
                              },
                            ),
                            PopupMenuButton<VehicleStatus>(
                              icon: const Icon(Icons.settings, size: 18),
                              tooltip: 'Change Status',
                              onSelected: (newStatus) {
                                v.status = newStatus;
                                provider.updateVehicle(v);
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: VehicleStatus.available, child: Text('Mark Available')),
                                const PopupMenuItem(value: VehicleStatus.underMaintenance, child: Text('Mark Under Maintenance')),
                                const PopupMenuItem(value: VehicleStatus.unavailable, child: Text('Mark Unavailable')),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              tooltip: 'Delete/Archive Car',
                              onPressed: () {
                                try {
                                  provider.deleteVehicle(v.id);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Car removed / archived.')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                }
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
