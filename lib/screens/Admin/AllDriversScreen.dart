import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/Driver.dart';
import 'ModifyDriverScreen.dart';

class AllDriversScreen extends StatefulWidget {
  const AllDriversScreen({super.key});

  @override
  _AllDriversScreenState createState() => _AllDriversScreenState();
}

class _AllDriversScreenState extends State<AllDriversScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Driver> _allDrivers = [];
  List<Driver> _filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
    _searchController.addListener(_filterDrivers);
  }

  Future<void> _fetchDrivers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Drivers').get();
    final drivers = querySnapshot.docs.map((doc) => Driver.fromMap(doc.data())).toList();
    setState(() {
      _allDrivers = drivers;
      _filteredDrivers = drivers;
    });
  }

  void _filterDrivers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDrivers = _allDrivers.where((driver) {
        return driver.name.toLowerCase().contains(query) ||
            driver.licenseNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Drivers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search drivers...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: _filteredDrivers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 3 / 4,
            ),
            itemCount: _filteredDrivers.length,
            itemBuilder: (context, index) {
              final driver = _filteredDrivers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModifyDriverScreen(driver: driver),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: driver.profileImageUrl.isNotEmpty
                            ? Image.asset(driver.profileImageUrl, fit: BoxFit.cover)
                            : Icon(Icons.person, size: 80, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        driver.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        driver.licenseNumber,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Status: ${driver.status}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
