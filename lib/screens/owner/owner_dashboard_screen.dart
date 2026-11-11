import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_logo.dart';
import '../auth/owner_login_screen.dart';
import 'inventory_screen.dart';
import 'customers_screen.dart';
import 'new_rental_flow_screen.dart';
import 'active_rentals_screen.dart';
import 'financials_screen.dart';
import 'settings_screen.dart';
import 'customer_documents_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentaro Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              provider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Owner / Business Admin'),
              accountEmail: Text(provider.companyName, maxLines: 1, overflow: TextOverflow.ellipsis),
              currentAccountPicture: const AppLogo(size: 48),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('New Rental'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewRentalFlowScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_shared),
              title: const Text('Customer Documents & Profiles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDocumentsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Car Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customer Directory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.car_rental),
              title: const Text('Active & Overdue Rentals'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRentalsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Financial Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings (Change Password)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final bool isTablet = screenWidth > 650;
          final int gridCols = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);
          final double cardAspectRatio = screenWidth > 900 ? 1.8 : (screenWidth > 600 ? 1.6 : 1.3);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Header
                Row(
                  children: [
                    const AppLogo(size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.companyName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${provider.companyAddress} • ${provider.companyPhone}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Customer Verification Documents Section Banner
                Card(
                  color: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDocumentsScreen()));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: const [
                          Icon(Icons.folder_shared, color: Colors.amber, size: 36),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer Documents & Verification',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'View A-to-Z profiles, CNIC images, live selfies, signatures & thumb impressions',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Grid
                const Text('Business Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: gridCols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cardAspectRatio,
                  children: [
                    _buildStatCard('Total Cars', '${provider.totalCars}', Icons.directions_car, Colors.blue),
                    _buildStatCard('Available Cars', '${provider.availableCars}', Icons.check_circle, Colors.green),
                    _buildStatCard('Currently Rented', '${provider.currentlyRentedCars}', Icons.car_rental, Colors.orange),
                    _buildStatCard('Active Rentals', '${provider.activeRentalsCount}', Icons.assignment, Colors.purple),
                    _buildStatCard('Overdue Rentals', '${provider.overdueRentalsCount}', Icons.warning, Colors.red),
                    _buildStatCard('Total Revenue', 'PKR ${provider.totalRevenue.toStringAsFixed(0)}', Icons.payments, Colors.teal),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (isTablet)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.add_circle),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('New Rental', style: TextStyle(fontWeight: FontWeight.bold))),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NewRentalFlowScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.car_rental),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Manage Rentals', style: TextStyle(fontWeight: FontWeight.bold))),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRentalsScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.directions_car),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Car Inventory')),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.people),
                          label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Search Customers')),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
                          },
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: const Icon(Icons.add_circle),
                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('New Rental', style: TextStyle(fontWeight: FontWeight.bold))),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewRentalFlowScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: const Icon(Icons.car_rental),
                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Manage Rentals', style: TextStyle(fontWeight: FontWeight.bold))),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRentalsScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              icon: const Icon(Icons.directions_car),
                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Car Inventory')),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              icon: const Icon(Icons.people),
                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Search Customers')),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
