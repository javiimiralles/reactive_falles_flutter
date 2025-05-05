import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../themes/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> fallas = [];
  bool isInfantiles = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFallas();
  }

  Future<void> fetchFallas() async {
    setState(() => isLoading = true);

    final tipo =
        isInfantiles ? 'falles-infantils-fallas-infantiles' : 'falles-fallas';
    final url = Uri.parse(
      'https://valencia.opendatasoft.com/api/explore/v2.1/catalog/datasets/$tipo/exports/geojson?lang=es',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes));
      final features = data['features'];
      setState(() {
        fallas = features;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

 void showFallaModal(BuildContext context, dynamic falla) {
  final props = falla['properties'];
  String imageUrl = props['boceto'] ?? '';
  imageUrl = imageUrl.replaceFirst('http:', 'https:');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 100),
                    ),
                  ),
                const SizedBox(height: 15),
                Text(
                  props['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Fallera: ${props['fallera'] ?? 'No disponible'}\n'
                  'Presidente: ${props['presidente'] ?? 'No disponible'}\n'
                  'Sección: ${props['seccion'] ?? ''}\n'
                  'Artista: ${props['artista'] ?? 'No disponible'}\n'
                  'Lema: ${props['lema'] ?? 'No disponible'}\n'
                  'Fundada en: ${props['anyo_fundacion'] ?? 'Desconocido'}\n'
                  'Distintivo: ${props['distintivo'] ?? 'Ninguno'}\n'
                  'Dirección: ${props['direccion'] ?? 'No disponible'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF555555),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget buildFallaItem(dynamic falla) {
    final props = falla['properties'];
    String imageUrl = props['boceto'] ?? '';
    imageUrl = imageUrl.replaceFirst('http:', 'https:');
    final proxyUrl = 'https://cors-anywhere.herokuapp.com/';
    final proxiedImageUrl = '$proxyUrl$imageUrl';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: () => showFallaModal(context, falla),
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            proxiedImageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
        title: Text(
          props['nombre'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${props['fallera'] ?? 'Sin fallera'} - ${props['seccion'] ?? ''}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Fallas 2025', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                const Text('Infantiles', style: TextStyle(color: Colors.white)),
                Switch(
                  value: isInfantiles,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.orange.shade700,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                  onChanged: (value) {
                    setState(() => isInfantiles = value);
                    fetchFallas();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: fallas.length,
                itemBuilder: (context, index) => buildFallaItem(fallas[index]),
              ),
    );
  }
}
