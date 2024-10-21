import 'package:flutter/material.dart';

class FilterOptions extends StatefulWidget {
  final Function(String, String, String, String) onApplyFilters; // Callback to apply filters

  const FilterOptions({Key? key, required this.onApplyFilters}) : super(key: key);

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  String selectedPriceRange = 'All';
  String selectedDuration = 'All';
  String selectedLayovers = 'All';
  String selectedAirline = 'All';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Range'),
          DropdownButton<String>(
            value: selectedPriceRange,
            onChanged: (value) {
              setState(() {
                selectedPriceRange = value!;
              });
            },
            items: <String>['All', 'Under \$100', '\$100 - \$300', 'Above \$300']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          SizedBox(height: 16.0),
          Text('Flight Duration'),
          DropdownButton<String>(
            value: selectedDuration,
            onChanged: (value) {
              setState(() {
                selectedDuration = value!;
              });
            },
            items: <String>['All', 'Under 2 hours', '2 - 5 hours', 'Above 5 hours']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          SizedBox(height: 16.0),
          Text('Layovers'),
          DropdownButton<String>(
            value: selectedLayovers,
            onChanged: (value) {
              setState(() {
                selectedLayovers = value!;
              });
            },
            items: <String>['All', 'Non-stop', '1 Layover', '2+ Layovers']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          SizedBox(height: 16.0),
          Text('Airlines'),
          DropdownButton<String>(
            value: selectedAirline,
            onChanged: (value) {
              setState(() {
                selectedAirline = value!;
              });
            },
            items: <String>['All', 'Airline A', 'Airline B', 'Airline C']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(
                selectedPriceRange,
                selectedDuration,
                selectedLayovers,
                selectedAirline,
              );
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
