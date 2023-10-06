import 'package:spare_parts/entities/inventory_item.dart';
import 'package:spare_parts/services/dymo_service.dart';

class PrintService {
  static void printQRCode(String printerName, InventoryItem item) {
    final label = openLabelXml(_getLabelXml(item));
    label.print(printerName);
  }

  static String _getLabelXml(InventoryItem item) {
    return '''<?xml version="1.0" encoding="utf-8"?>
      <DieCutLabel Version="8.0" Units="twips">
          <PaperOrientation>Landscape</PaperOrientation>
          <Id>NameBadgeTag</Id>
          <PaperName>30252 Address</PaperName>
          <ObjectInfo>
            <TextObject>
                <Name>Signature</Name>
                <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
                <BackColor Alpha="0" Red="255" Green="255" Blue="255" />
                <LinkedObjectName></LinkedObjectName>
                <Rotation>Rotation0</Rotation>
                <IsMirrored>False</IsMirrored>
                <IsVariable>True</IsVariable>
                <HorizontalAlignment>Center</HorizontalAlignment>
                <VerticalAlignment>Middle</VerticalAlignment>
                <TextFitMode>ShrinkToFit</TextFitMode>
                <UseFullFontHeight>True</UseFullFontHeight>
                <Verticalized>False</Verticalized>
                <StyledText>
                    <Element>
                        <String>Property of Vehikl Inc.</String>
                        <Attributes>
                            <Font Family="Arial" Size="6" Bold="False" Italic="False" Underline="False" Strikeout="False" />
                            <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
                        </Attributes>
                    </Element>
                </StyledText>
            </TextObject>
            <Bounds X="0" Y="200" Width="1200" Height="200" />
          </ObjectInfo>
          <ObjectInfo>
              <BarcodeObject>
                  <Name>QRCode</Name>
                  <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
                  <BackColor Alpha="0" Red="255" Green="255" Blue="255" />
                  <LinkedObjectName></LinkedObjectName>
                  <Rotation>Rotation0</Rotation>
                  <IsMirrored>False</IsMirrored>
                  <IsVariable>False</IsVariable>
                  <Text>${item.id}</Text>
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
              <Bounds X="0" Y="200" Width="1200" Height="1400" />
          </ObjectInfo>
          <ObjectInfo>
            <TextObject>
                <Name>Name</Name>
                <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
                <BackColor Alpha="0" Red="255" Green="255" Blue="255" />
                <LinkedObjectName></LinkedObjectName>
                <Rotation>Rotation0</Rotation>
                <IsMirrored>False</IsMirrored>
                <IsVariable>True</IsVariable>
                <HorizontalAlignment>Center</HorizontalAlignment>
                <VerticalAlignment>Middle</VerticalAlignment>
                <TextFitMode>ShrinkToFit</TextFitMode>
                <UseFullFontHeight>True</UseFullFontHeight>
                <Verticalized>False</Verticalized>
                <StyledText>
                    <Element>
                        <String>${item.nameForPrinting}</String>
                        <Attributes>
                            <Font Family="Monospace" Size="6" Bold="False" Italic="False" Underline="False" Strikeout="False" />
                            <ForeColor Alpha="255" Red="0" Green="0" Blue="0" />
                        </Attributes>
                    </Element>
                </StyledText>
            </TextObject>
            <Bounds X="0" Y="1300" Width="800" Height="100" />
          </ObjectInfo>
      </DieCutLabel>''';
  }
}
