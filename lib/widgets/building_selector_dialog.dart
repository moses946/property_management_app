import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/building_provider.dart';
// import '../models/building.dart';

class BuildingSelectorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Building',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Consumer<BuildingProvider>(
              builder: (ctx, buildingProvider, _) {
                final buildings = buildingProvider.buildings;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: buildings.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(buildings[index].name),
                    subtitle: Text(buildings[index].location),
                    onTap: () {
                      Navigator.of(context).pop(buildings[index]);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
