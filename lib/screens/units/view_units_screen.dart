// screens/unit/view_units_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unit_provider.dart';
// import '../../models/unit.dart';

class ViewUnitsScreen extends StatelessWidget {
  final String buildingId;

  ViewUnitsScreen({required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Units')),
      body: FutureBuilder(
        future: Provider.of<UnitProvider>(context, listen: false)
            .fetchUnitsForBuilding(buildingId),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : Consumer<UnitProvider>(
                    builder: (ctx, unitProvider, _) => ListView.builder(
                      itemCount: unitProvider.units.length,
                      itemBuilder: (ctx, i) => ListTile(
                        title: Text(unitProvider.units[i].name),
                        subtitle: Text('Rent: \$${unitProvider.units[i].rent}'),
                        onTap: () {
                          // Navigate to Unit Details Screen or Edit Unit
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
