import 'package:spare_parts/services/dymo_service.dart';

class PrintService {
  static void printQRCode(String printerName, String itemId) {
    final label = openLabelXml(_getLabelXml(itemId));
    label.print(printerName);
  }

  static String _getLabelXml(String itemId) {
    return '''<?xml version="1.0" encoding="utf-8"?>
      <DieCutLabel Version="8.0" Units="twips">
          <PaperOrientation>Landscape</PaperOrientation>
          <Id>NameBadgeTag</Id>
          <PaperName>30252 Address</PaperName>
          <ObjectInfo>
              <BarcodeObject>
                  <Name>QRBarcode</Name>
                  <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
                  <BackColor Alpha="0" Red="255" Green="255" Blue="255" />
                  <LinkedObjectName></LinkedObjectName>
                  <Rotation>Rotation0</Rotation>
                  <IsMirrored>False</IsMirrored>
                  <IsVariable>False</IsVariable>
                  <Text>$itemId</Text>
                  <Type>QRCode</Type>
                  <Size>Large</Size>
                  <TextPosition>None</TextPosition>
                  <TextFont Family="Arial" Size="8" Bold="False" Italic="False" Underline="False" Strikeout="False" />
                  <CheckSumFont Family="Arial" Size="8" Bold="False" Italic="False" Underline="False" Strikeout="False" />
                  <TextEmbedding>None</TextEmbedding>
                  <ECLevel>0</ECLevel>
                  <HorizontalAlignment>Center</HorizontalAlignment>
                  <QuietZonesPadding Left="0" Top="0" Right="0" Bottom="0" />
              </BarcodeObject>
              <Bounds X="0" Y="0" Width="1600" Height="1600" />
          </ObjectInfo>
      </DieCutLabel>''';
  }
}
