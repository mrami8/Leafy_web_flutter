import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/leafy_layout.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir direcciones en Google Maps

class FlowerStoreScreen extends StatelessWidget {
  const FlowerStoreScreen({super.key});

  void _openInGoogleMaps(double lat, double lng) async {
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LeafyLayout(
      showSearchBar: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Floristerías Cercanas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Lista ficticia de floristerías
            Expanded(
              child: ListView(
                children: [
                  _buildStoreCard(
                    context,
                    name: 'Floristería Gardenia',
                    address: 'Calle Primavera 123',
                    lat: 40.4168,
                    lng: -3.7038,
                  ),
                  _buildStoreCard(
                    context,
                    name: 'Viveros Naturaleza',
                    address: 'Avenida Verde 45',
                    lat: 40.4178,
                    lng: -3.7045,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context,
      {required String name,
      required String address,
      required double lat,
      required double lng}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.local_florist, color: Colors.green, size: 36),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address),
        trailing: IconButton(
          icon: const Icon(Icons.map_outlined),
          onPressed: () => _openInGoogleMaps(lat, lng),
        ),
      ),
    );
  }
}
