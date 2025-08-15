
import 'package:flutter/material.dart';

class LostItemsScreen extends StatefulWidget {
  const LostItemsScreen({super.key});

  @override
  State<LostItemsScreen> createState() => _LostItemsScreenState();
}

class _LostItemsScreenState extends State<LostItemsScreen> {
  final List<Map<String, String>> allItems = const [
    {
      "title": "Fossil Men's Watch",
      "id": "MC041",
      "location": "MAIN CANTEEN",
      "date": "21/07/2025 - 04:35 PM",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrPIrGNpAYW5S2dqvyIS9v4ze5k3oRDVYmSg&s"
    },
    {
      "title": "Black Backpack",
      "id": "BK012",
      "location": "LIBRARY",
      "date": "15/07/2025 - 02:10 PM",
      "image": "https://www.fgear.in/cdn/shop/files/1_9822ae18-0551-41fa-8cc1-1745a1359531.jpg?v=1717826522&width=1946"
    },
    {
      "title": "iPhone 14 Pro",
      "id": "IP003",
      "location": "LIBRARY",
      "date": "20/07/2025 - 01:20 PM",
      "image": "https://easyphones.co.in/cdn/shop/files/52.png?v=1736145827"
    },
    {
      "title": "Blue Water Bottle",
      "id": "WB007",
      "location": "MAIN CANTEEN",
      "date": "19/07/2025 - 03:45 PM",
      "image": "https://femora.in/cdn/shop/files/FMSTLTTR-01_1.jpg?v=1713001295"
    },
  ];

  List<Map<String, String>> filteredItems = [];
  String searchQuery = '';
  String selectedLocation = 'All';
  bool sortByDateAscending = false;

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(allItems);
  }

  void _applyFiltersAndSort() {
    setState(() {
      // Start with all items
      filteredItems = List.from(allItems);

      
      if (searchQuery.isNotEmpty) {
        filteredItems = filteredItems.where((item) {
          return item['title']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();
      }

     
      if (selectedLocation != 'All') {
        filteredItems = filteredItems.where((item) {
          return item['location'] == selectedLocation;
        }).toList();
      }

      
      filteredItems.sort((a, b) {
        DateTime dateA = _parseDate(a['date']!);
        DateTime dateB = _parseDate(b['date']!);
        
        if (sortByDateAscending) {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });
    });
  }

  DateTime _parseDate(String dateString) {
    // Parse "21/07/2025 - 04:35 PM" format
    String datePart = dateString.split(' - ')[0];
    List<String> parts = datePart.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter by Location'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('All'),
                    value: 'All',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Main Canteen'),
                    value: 'MAIN CANTEEN',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Library'),
                    value: 'LIBRARY',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('AB1'),
                    value: 'AB1',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('AB2'),
                    value: 'AB2',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('AB3'),
                    value: 'AB3',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('AB4'),
                    value: 'AB4',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('IT CANTEEN'),
                    value: 'IT CANTEEN',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('MBA CANTEEN'),
                    value: 'MBA CANTEEN',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                  
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFiltersAndSort();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort by Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Newest First'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: sortByDateAscending,
                  onChanged: (value) {
                    setState(() {
                      sortByDateAscending = value!;
                    });
                    _applyFiltersAndSort();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: const Text('Oldest First'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: sortByDateAscending,
                  onChanged: (value) {
                    setState(() {
                      sortByDateAscending = value!;
                    });
                    _applyFiltersAndSort();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
    TextEditingController searchController = TextEditingController(text: searchQuery);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Items'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter item name...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                searchQuery = searchController.text;
                _applyFiltersAndSort();
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5316B),
        elevation: 0,
        title: const Text("Lost Items" , style:TextStyle(color: Colors.white ,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTopButton("Filter", _showFilterDialog),
                _buildTopButton("Sort", _showSortDialog),
                _buildTopButton("Search", _showSearchDialog),
              ],
            ),
          ),
          // Show current filters
          if (selectedLocation != 'All' || searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Active filters: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (selectedLocation != 'All')
                    Chip(
                      label: Text(selectedLocation),
                      onDeleted: () {
                        setState(() {
                          selectedLocation = 'All';
                        });
                        _applyFiltersAndSort();
                      },
                    ),
                  if (searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Search: $searchQuery'),
                      onDeleted: () {
                        setState(() {
                          searchQuery = '';
                        });
                        _applyFiltersAndSort();
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item["title"]!,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text("#${item["id"]}"),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.pink),
                                          const SizedBox(width: 4),
                                          Text(item["location"]!),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(item["date"]!),
                                      const SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () {
                                          // Later: Navigate to item details
                                        },
                                        child: const Text(
                                          "View Details >",
                                          style: TextStyle(
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item["image"]!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD5316B),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}