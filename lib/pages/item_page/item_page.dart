import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/pages/item_page/item_history.dart';
import 'package:spare_parts/services/dymo_service.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/error_container.dart';
import 'package:spare_parts/widgets/item_actions_button.dart';
import 'package:spare_parts/widgets/item_icon.dart';

class ItemPage extends StatefulWidget {
  final String itemId;

  const ItemPage({super.key, required this.itemId});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  FirestoreService get firestoreService => context.watch<FirestoreService>();
  UserRole get userRole => context.watch<UserRole>();

  @override
  void initState() {
    super.initState();
    init();
  }

  void printLabel() {
    final label = openLabelXml('''<?xml version="1.0" encoding="utf-8"?>
<DieCutLabel Version="8.0" Units="twips">
    <PaperOrientation>Landscape</PaperOrientation>
    <Id>NameBadgeTag</Id>
    <PaperName>30252 Address</PaperName>
    <ObjectInfo>
        <ImageObject>
            <Name>photo</Name>
            <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
            <BackColor Alpha="0" Red="0" Green="0" Blue="0" />
            <LinkedObjectName></LinkedObjectName>
            <Rotation>Rotation0</Rotation>
            <IsMirrored>False</IsMirrored>
            <IsVariable>False</IsVariable>
            <Image>
                iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAABgAAAAYADwa0LPAAAFgklEQVR42u3dMY4TQRBAURtxC8u+/7kc+BpDsGyASHaAZuqP34uR1R4PXxVsqa/btm0XgIBvRx8A4KsEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMr4ffYBPt9vt8nq9jj5GyrZtX/631+v18M+d8By8Z/vteb6rmbCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyxqzm7PF8Pi/3+/3oYyyxanVk0npF5bzes3lMWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARnJ1Zw9are61J5D7YadVSZ8twnv2WomLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgIzTr+Ywx6o1nndYSeGDCQvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCDDag6/WbXqYt2Gv2XCAjIEC8gQLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyDj9ao4Vjw+rbqxZpbbGM+EM78CEBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkJFczXk8HkcfIWfVqsuEz13FezaPCQvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCDjurnug/9k1bqNV/h9mLCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyxtyaM+GWlD1WrYOc+RaaVVY9s1VnWGXCbUermbCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyxtyaU1sVmHDeCWs8Z14PmvC7TTDh/9snExaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWEDGmFtzJqx47DnDmdc2ar8FHyb8bquZsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjLGrObUbqFZ5czfbYLac5hw29EkJiwgQ7CADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICM6zbkb/Qn3L6yarVhwnfbY8J5J6yZTDgDvzJhARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZIxZzWEt6zZzzjBB9TmYsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgAzBAjLGrObcbrfL6/U6+hgptfWVCetBE55D7QyTmLCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyvh99gD/xfD4v9/v96GMsMWFFadWKx5lXR6wd/R8mLCBDsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIEOwgIzkas4eq1Ym9pi02vAVE9ZMJvxuq6x6Dns+t/ZOfjJhARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZJx+NYcPE25JOfMZ9nzuhOdQZcICMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyBAvIsJrDX5mw6lJb4+HPmbCADMECMgQLyBAsIEOwgAzBAjIEC8gQLCBDsIAMwQIyTr+aY2WiqbbGs8qe77ZH7Tl8MmEBGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkJFdzHo/H0Ufgp+qKx7+2aoVmj3f4LUxYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGdftHf6eHzgFExaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWEDGDzAUJFjxRzIvAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIzLTAzLTAyVDIxOjUwOjA3KzAwOjAwmRrnnAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMy0wMy0wMlQyMTo1MDowNyswMDowMOhHXyAAAAAASUVORK5CYII=</Image>
            <ScaleMode>Uniform</ScaleMode>
            <BorderWidth>0</BorderWidth>
            <BorderColor Alpha="255" Red="0" Green="0" Blue="0" />
            <HorizontalAlignment>Center</HorizontalAlignment>
            <VerticalAlignment>Center</VerticalAlignment>
        </ImageObject>
        <Bounds X="0" Y="0" Width="1200" Height="1200" />
    </ObjectInfo>
</DieCutLabel>''');
    label.print(getPrinters()[0].name);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: firestoreService.getItemStream(widget.itemId),
        builder: (context, AsyncSnapshot<InventoryItem> snapshot) {
          if (snapshot.hasError) {
            return ErrorContainer(error: snapshot.error.toString());
          }

          final item = snapshot.data;
          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Loading...')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: Text(item.name)),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: ItemIcon(item: item),
                        title: Text(item.name, style: TextStyle(fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tag_rounded),
                                Text(item.id),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.domain_rounded),
                                Text(item.storageLocation != null
                                    ? item.storageLocation!
                                    : 'N/A'),
                              ],
                            ),
                            if (item.description != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    'Description:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(item.description!),
                                ],
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: ItemActionsButton(item: item),
                      ),
                    ),
                  ),
                  // Text(
                  //     'Browser supported: ${checkEnvironment().isBrowserSupported}'),
                  // Text(
                  //     'Framework installed: ${checkEnvironment().isFrameworkInstalled}'),
                  // Text(
                  //     'Webservice present: ${checkEnvironment().isWebServicePresent}'),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: getPrinters().length,
                    itemBuilder: (context, index) {
                      return Text(getPrinters()[index].name);
                    },
                  ),
                  ElevatedButton(onPressed: printLabel, child: Text('Print')),
                  SizedBox(height: 20),
                  if (userRole == UserRole.admin)
                    Expanded(child: ItemHistory(itemId: item.id))
                ],
              ),
            ),
          );
        });
  }
}
