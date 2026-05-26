import 'package:flutter/material.dart';

void main() {
  runApp(const MEnergyApp());
}

class MEnergyApp extends StatelessWidget {
  const MEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M Energy Aungywa Admin',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A132C), // Deep Navy Blue
        primaryColor: const Color(0xFFFF6A1F), // Neon Orange
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

// ==========================================
// ðŸ—„ï¸ DATABASE LAYER (á€’á€±á€á€¬á€˜á€±á€·á€…á€º á€…á€”á€…á€º)
// ==========================================
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  int points;
  CustomerModel({required this.id, required this.name, required this.phone, required this.points});
}

class TransactionModel {
  final String id;
  final String title;
  final String time;
  final String points;
  TransactionModel({required this.id, required this.title, required this.time, required this.points});
}

// á€œá€€á€ºá€á€½á€±á€· Database á€žá€˜á€±á€¬á€™á€»á€­á€¯á€¸ á€¡á€œá€¯á€•á€ºá€œá€¯á€•á€ºá€™á€Šá€·á€º Central Data Store
class LocalDatabase {
  // áá‹ á€¡á€žá€¯á€¶á€¸á€•á€¼á€¯á€žá€° á€…á€¬á€›á€„á€ºá€¸ á€žá€­á€™á€ºá€¸á€†á€Šá€ºá€¸á€žá€Šá€·á€º Database Table
  static List<CustomerModel> customerTable = [
    CustomerModel(id: "USR-01", name: "á€¦á€¸á€™á€¼", phone: "0912345678", points: 150),
    CustomerModel(id: "USR-02", name: "á€’á€±á€«á€ºá€œá€¾", phone: "0987654321", points: 320),
    CustomerModel(id: "USR-03", name: "á€™á€±á€¬á€„á€ºá€€á€±á€¬á€„á€ºá€¸", phone: "0944455566", points: 45),
    CustomerModel(id: "USR-04", name: "á€€á€­á€¯á€‡á€±á€¬á€º", phone: "0977788899", points: 600),
  ];

  // á‚á‹ á€œá€¯á€•á€ºá€†á€±á€¬á€„á€ºá€á€»á€€á€º á€™á€¾á€á€ºá€á€™á€ºá€¸á€™á€»á€¬á€¸ á€žá€­á€™á€ºá€¸á€†á€Šá€ºá€¸á€žá€Šá€·á€º Database Table
  static List<TransactionModel> transactionTable = [
    TransactionModel(id: "TXN-01", title: "á€¡á€™á€¾á€á€ºá€‘á€Šá€·á€ºá€žá€½á€„á€ºá€¸á€á€¼á€„á€ºá€¸ (á€¦á€¸á€™á€¼)", time: "12:25", points: "+50 Pts"),
    TransactionModel(id: "TXN-02", title: "á€…á€½á€™á€ºá€¸á€¡á€„á€ºá€–á€¼á€Šá€·á€ºá€á€„á€ºá€¸á€á€¼á€„á€ºá€¸ (á€’á€±á€«á€ºá€œá€¾)", time: "12:26", points: "+100 Pts"),
  ];

  // áƒá‹ Database Query Functions (á€’á€±á€á€¬ á€›á€¾á€¬á€–á€½á€±/á€•á€¼á€„á€ºá€†á€„á€ºá€žá€Šá€·á€º á€…á€”á€…á€ºá€™á€»á€¬á€¸)
  static List<CustomerModel> searchCustomers(String query) {
    if (query.isEmpty) return customerTable;
    return customerTable.where((customer) => 
      customer.id.toLowerCase().contains(query.toLowerCase()) || 
      customer.phone.contains(query) ||
      customer.name.contains(query)
    ).toList();
  }

  static void addPoints(String customerId, int points) {
    // Database á€‘á€²á€á€½á€„á€º á€¡á€™á€¾á€á€ºá€žá€½á€¬á€¸á€•á€±á€«á€„á€ºá€¸á€‘á€Šá€·á€ºá€á€¼á€„á€ºá€¸
    final customer = customerTable.firstWhere((c) => c.id == customerId);
    customer.points += points;

    // Transaction Table á€‘á€²á€žá€­á€¯á€· á€…á€¬á€›á€„á€ºá€¸á€¡á€žá€…á€º á€žá€½á€¬á€¸á€žá€­á€™á€ºá€¸á€á€¼á€„á€ºá€¸
    final now = DateTime.now();
    final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    transactionTable.insert(0, TransactionModel(
      id: "TXN-${transactionTable.length + 1}",
      title: "Scan á€–á€á€ºá á€¡á€™á€¾á€á€ºá€‘á€Šá€·á€ºá€á€¼á€„á€ºá€¸ (${customer.name})",
      time: timeStr,
      points: "+$points Pts",
    ));
  }

  static int getTotalPointsGiven() {
    return transactionTable.fold(0, (sum, item) {
      final pts = int.tryParse(item.points.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + pts;
    });
  }
}

// ==========================================
// ðŸ“± UI LAYER (á€™á€»á€€á€ºá€”á€¾á€¬á€•á€¼á€„á€º á€¡á€•á€­á€¯á€„á€ºá€¸)
// ==========================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchResults = LocalDatabase.customerTable;
  }

  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults = LocalDatabase.searchCustomers(query);
    });
  }

  // QR Code á€–á€á€ºá€•á€¼á€®á€¸ á€¡á€™á€¾á€á€ºá€á€­á€¯á€¸á€•á€±á€¸á€žá€Šá€·á€º á€’á€±á€á€¬á€˜á€±á€·á€…á€º á€…á€”á€…á€ºá€¡á€¬á€¸ á€…á€™á€ºá€¸á€žá€•á€ºá€á€¼á€„á€ºá€¸
  void _simulateScanAndSaveDatabase() {
    // á€’á€±á€á€¬á€˜á€±á€·á€…á€ºá€‘á€²á€™á€¾ á€•á€‘á€™á€†á€¯á€¶á€¸á€œá€°á€€á€­á€¯ á€…á€™á€ºá€¸á€žá€•á€º á€›á€½á€±á€¸á€á€»á€šá€ºá€•á€¼á€®á€¸ á€¡á€™á€¾á€á€º á…á€ á€•á€±á€¸á€á€¼á€„á€ºá€¸
    final testCustomer = LocalDatabase.customerTable[0]; 
    
    setState(() {
      LocalDatabase.addPoints(testCustomer.id, 50);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF6A1F),
        content: Text("Database Updated: ${testCustomer.name} á€‘á€¶ á€¡á€™á€¾á€á€º 50 Pts á€‘á€Šá€·á€ºá€žá€½á€„á€ºá€¸á€•á€¼á€®á€¸á€•á€«á€•á€¼á€®á‹"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header & Profile
              Text("MONDAY, MAY 25, 2026", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              const SizedBox(height: 6),
              const Text("M Energy Aungywa", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("á€á€”á€ºá€‘á€™á€ºá€¸ á€¡á€€á€ºá€•á€œá€®á€€á€±á€¸á€›á€¾á€„á€ºá€¸ (Admin Console)", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              
              // Admin Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Colors.orange, child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("á€…á€®á€™á€¶á€á€”á€·á€ºá€á€½á€²á€žá€°: á€€á€­á€¯á€€á€­á€¯ (Ko Ko)", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // User Management Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF152238),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF6A1F), width: 1.2),
                ),
                child: Column(
                  children: [
                    const Text("á€žá€¯á€¶á€¸á€…á€½á€²á€žá€° á€…á€®á€™á€¶á€á€”á€·á€ºá€á€½á€²á€™á€¾á€¯ (User Management)", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    // Live Search TextField
                    TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      decoration: InputDecoration(
                        hintText: "IDáŠ á€¡á€™á€Šá€º á€žá€­á€¯á€·á€™á€Ÿá€¯á€á€º á€–á€¯á€”á€ºá€¸á€–á€¼á€„á€·á€º á€›á€¾á€¬á€–á€½á€±á€›á€”á€º...",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                        suffixIcon: _isSearching ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); _handleSearch(""); }) : null,
                        filled: true,
                        fillColor: const Color(0xFF0A132C),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.qr_code_2, size: 60, color: Colors.white),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6A1F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          onPressed: _simulateScanAndSaveDatabase, 
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                          label: const Text("Scan & Save DB", style: TextStyle(color: Colors.white, fontSize: 12)),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Live Search Results á€žá€­á€¯á€·á€™á€Ÿá€¯á€á€º Recent Transactions á€•á€¼á€žá€•á€±á€¸á€™á€Šá€·á€º á€”á€±á€›á€¬
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF152238), borderRadius: BorderRadius.circular(14)),
                  child: _isSearching 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("á€›á€¾á€¬á€–á€½á€±á€á€½á€±á€·á€›á€¾á€­á€™á€¾á€¯ á€›á€œá€’á€ºá€™á€»á€¬á€¸ (${_searchResults.length})", style: const TextStyle(color: Color(0xFFFF6A1F), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final res = _searchResults[index];
                                return ListTile(
                                  title: Text(res.name, style: const TextStyle(fontSize: 13)),
                                  subtitle: Text("${res.id} | ${res.phone}", style: const TextStyle(fontSize: 11)),
                                  trailing: Text("${res.points} Pts", style: const TextStyle(color: Color(0xFFFF6A1F), fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text("á€’á€±á€á€¬á€˜á€±á€·á€…á€º á€™á€¾á€á€ºá€á€™á€ºá€¸á€™á€»á€¬á€¸ (Recent DB Logs)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: LocalDatabase.transactionTable.length,
                              itemBuilder: (context, index) {
                                final log = LocalDatabase.transactionTable[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(log.title, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                      Text(log.points, style: const TextStyle(color: Color(0xFFFF6A1F), fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text(log.time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                      const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomButton(Icons.people, "á€¡á€žá€¯á€¶á€¸á€•á€¼á€¯á€žá€° á€…á€¬á€›á€„á€ºá€¸\n(View DB Tables)", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DBTableScreen()));
                  }),
                  _buildBottomButton(Icons.bar_chart, "á€¡á€…á€®á€›á€„á€ºá€á€¶á€…á€¬á€™á€»á€¬á€¸\n(DB Metrics)", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DBMetricsScreen()));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF152238),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF6A1F), width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// --- SUB SCREEN: CUSTOMER TABLE VIEW ---
class DBTableScreen extends StatelessWidget {
  const DBTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer DB Table"), backgroundColor: const Color(0xFF152238)),
      body: ListView.builder(
        itemCount: LocalDatabase.customerTable.length,
        itemBuilder: (context, index) {
          final c = LocalDatabase.customerTable[index];
          return Card(
            color: const Color(0xFF152238),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.storage, color: Color(0xFFFF6A1F)),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("ID: ${c.id} | Phone: ${c.phone}", style: const TextStyle(fontSize: 12)),
              trailing: Text("${c.points} Pts", style: const TextStyle(color: Color(0xFFFF6A1F), fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

// --- SUB SCREEN: DATABASE METRICS & REPORTS ---
class DBMetricsScreen extends StatelessWidget {
  const DBMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Database Metrics"), backgroundColor: const Color(0xFF152238)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildMetricTile("á€…á€¯á€…á€¯á€•á€±á€«á€„á€ºá€¸ Customer á€¡á€€á€±á€¬á€„á€·á€ºá€¡á€›á€±á€¡á€á€½á€€á€º", "${LocalDatabase.customerTable.length} á€á€¯", Icons.supervised_user_circle),
            const SizedBox(height: 12),
            _buildMetricTile("á€…á€¯á€…á€¯á€•á€±á€«á€„á€ºá€¸ á€•á€±á€¸á€•á€¼á€®á€¸á€žá€™á€»á€¾ Point á€•á€™á€¬á€", "${LocalDatabase.getTotalPointsGiven()} Pts", Icons.OfflineBolt),
            const SizedBox(height: 12),
            _buildMetricTile("á€…á€¯á€…á€¯á€•á€±á€«á€„á€ºá€¸ á€’á€±á€á€¬á€˜á€±á€·á€…á€º á€…á€¬á€›á€„á€ºá€¸á€™á€¾á€á€ºá€á€™á€ºá€¸ (Logs)", "${LocalDatabase.transactionTable.length} á€á€¯", Icons.history_edu),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF152238), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6A1F), size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
