import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCVCardShare extends StatefulWidget {
  @override
  _NFCVCardShareState createState() => _NFCVCardShareState();
}

class _NFCVCardShareState extends State<NFCVCardShare> {
  bool _nfcAvailable = false;

  @override
  void initState() {
    super.initState();
    // Check if NFC is available on the device
    NfcManager.instance.isAvailable().then((isAvailable) {
      setState(() {
        _nfcAvailable = isAvailable;
      });
    });
  }

 void _shareVCard() async {
  if (!_nfcAvailable) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('NFC is not available on this device')),
    );
    return;
  }

  // Create a vCard string
  String vCard = '''
  BEGIN:VCARD
  VERSION:3.0
  FN:Muhammad Usman
  TEL:03197344951
  EMAIL:MuhammadUsman@alisonstech.com
  END:VCARD
  ''';

  // Convert the vCard string into Uint8List
  Uint8List vCardBytes = Uint8List.fromList(vCard.codeUnits);

  try {
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tag is not writable')),
          );
          return;
        }

        // Create an NDEF record with MIME type
        final record = NdefRecord.createMime(
          'text/vcard', // MIME type for vCard
          vCardBytes,
        );

        // Write the NDEF message
        await ndef.write(NdefMessage([record]));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('vCard shared successfully')),
        );

        await NfcManager.instance.stopSession();
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing vCard: $e')),
    );
    await NfcManager.instance.stopSession();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC vCard Share', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400]
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _shareVCard,
          child: Text('Share vCard via NFC'),
        ),
      ),
    );
  }
}
