// screens/building/view_building_screen.dart

import 'package:flutter/material.dart';
import 'package:property_management_app/screens/units/add_unit_screen.dart';
import 'package:property_management_app/screens/units/edit_unit_screen.dart';
import 'package:provider/provider.dart';
// import '../../providers/building_provider.dart';
import '../../providers/unit_provider.dart';
import '../../models/building.dart';
// import '../../models/unit.dart';
// import '../unit/edit_unit_screen.dart';
// import '../unit/add_unit_screen.dart';

class ViewBuildingScreen extends StatefulWidget {
  final Building building;

  ViewBuildingScreen({required this.building});

  @override
  _ViewBuildingScreenState createState() => _ViewBuildingScreenState();
}

class _ViewBuildingScreenState extends State<ViewBuildingScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      print("no error yet");
      Provider.of<UnitProvider>(context, listen: false)
          .fetchUnitsForBuilding(widget.building.id);
      _isInitialized = true;
      print("now after error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Building: ${widget.building.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      AddUnitScreen(buildingId: widget.building.id),
                ),
              );
              if (result == true) {
                Provider.of<UnitProvider>(context, listen: false)
                    .fetchUnitsForBuilding(widget.building.id);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Building Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Location: ${widget.building.location}'),
                Text('Total Floors: ${widget.building.totalFloors}'),
                Text('Units per Floor: ${widget.building.unitsPerFloor}'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Units',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Consumer<UnitProvider>(
              builder: (context, unitProvider, _) {
                if (unitProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (unitProvider.error != null &&
                    unitProvider.error!.isNotEmpty) {
                  return Center(child: Text(unitProvider.error!));
                }

                final units = unitProvider.units;
                return units.isEmpty
                    ? Center(child: Text('No units available'))
                    : ListView.builder(
                        itemCount: units.length,
                        itemBuilder: (ctx, index) {
                          final unit = units[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(unit.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text('Unit Name: ${unit.name}'),
                                  Text('Floor Number: ${unit.floorNumber}'),
                                  Text('Type: ${unit.type}'),
                                  Text('Occupancy Status: ${unit.status}'),
                                  Text('Rent: Ksh. ${unit.rent}'),
                                  Text('Garbage Fee: ${unit.garbageFee}'),
                                  Text(
                                      'Water Price Per Unit: Ksh. ${unit.costOfWater}'),
                                  Text(
                                      'Total Consumed Units: Ksh. ${unit.waterUnitsConsumed}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          EditUnitScreen(unit: unit),
                                    ),
                                  );
                                  if (result == true) {
                                    Provider.of<UnitProvider>(context,
                                            listen: false)
                                        .fetchUnitsForBuilding(
                                            widget.building.id);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Provider.of<UnitProvider>(context, listen: false).clearUnits();
    super.dispose();
  }
}
