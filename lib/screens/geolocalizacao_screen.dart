import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  const GeolocalizacaoScreen({super.key});

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  final _locationService = LocationService();
  Position? _posicaoAtual;
  bool _carregando = false;
  String? _mensagemErro;
  StreamSubscription<Position>? _positionStreamSub;
  bool _rastreando = false;

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });
    try {
      final posicao = await _locationService.obterPosicaoAtual();
      setState(() => _posicaoAtual = posicao);
    } catch (e) {
      setState(() => _mensagemErro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _alternarRastreamento() {
    if (_rastreando) {
      _positionStreamSub?.cancel();
      setState(() => _rastreando = false);
    } else {
      setState(() => _rastreando = true);
      _positionStreamSub = _locationService.monitorarPosicao().listen(
        (pos) => setState(() => _posicaoAtual = pos),
        onError: (err) => setState(() => _mensagemErro = err.toString()),
      );
    }
  }

  // Desafio Avançado: Abrir no Google Maps com url_launcher
  Future<void> _abrirNoGoogleMaps() async {
    if (_posicaoAtual == null) return;
    final Uri url = Uri.parse(
      'https://maps.google.com/?q=${_posicaoAtual!.latitude},${_posicaoAtual!.longitude}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        setState(() {
          _mensagemErro = 'Não foi possível abrir o Google Maps.';
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro ao abrir mapa: $e';
      });
    }
  }

  // Desafio Básico: Medidor de Precisão com Chip visual colorido
  Widget _buildPrecisionChip(double accuracy) {
    Color chipColor;
    Color textColor;
    String status;

    if (accuracy < 15) {
      chipColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
      status = 'Precisão Alta (< 15m)';
    } else if (accuracy <= 50) {
      chipColor = Colors.amber.shade100;
      textColor = Colors.amber.shade900;
      status = 'Precisão Média (15-50m)';
    } else {
      chipColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
      status = 'Precisão Baixa (> 50m)';
    }

    return Chip(
      backgroundColor: chipColor,
      side: BorderSide(color: textColor.withOpacity(0.4)),
      avatar: Icon(Icons.gps_fixed, size: 18, color: textColor),
      label: Text(
        '$status: ${accuracy.toStringAsFixed(1)}m',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Desafio Intermediário: Cálculo de distância até Fatec Matão
    double? distanciaFatec;
    if (_posicaoAtual != null) {
      distanciaFatec = _locationService.calcularDistanciaAteFatecMatao(
        _posicaoAtual!.latitude,
        _posicaoAtual!.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in & GPS'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_carregando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_mensagemErro != null)
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _mensagemErro!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              if (_posicaoAtual != null) ...[
                Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.my_location, color: Colors.blue),
                        title: const Text('Latitude'),
                        subtitle: Text('${_posicaoAtual!.latitude}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: const Text('Longitude'),
                        subtitle: Text('${_posicaoAtual!.longitude}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.speed, color: Colors.orange),
                        title: const Text('Precisão / Altitude'),
                        subtitle: Text(
                          'Precisão: ${_posicaoAtual!.accuracy.toStringAsFixed(1)}m | Alt: ${_posicaoAtual!.altitude.toStringAsFixed(1)}m',
                        ),
                      ),
                      // Desafio Básico: Chip de Indicador de Precisão
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildPrecisionChip(_posicaoAtual!.accuracy),
                        ),
                      ),
                      const Divider(),
                      // Desafio Intermediário: Distância até a Fatec Matão
                      ListTile(
                        leading: const Icon(Icons.school, color: Colors.indigo),
                        title: const Text('Distância até a Fatec Matão'),
                        subtitle: Text(
                          distanciaFatec! >= 1000
                              ? '${(distanciaFatec / 1000).toStringAsFixed(2)} km (${distanciaFatec.toStringAsFixed(0)} m)'
                              : '${distanciaFatec.toStringAsFixed(1)} metros',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      // Desafio Avançado: Botão de Abrir no Google Maps
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _abrirNoGoogleMaps,
                          icon: const Icon(Icons.map),
                          label: const Text('Abrir no Google Maps'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _carregando ? null : _buscarLocalizacao,
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Capturar Localização Atual'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _alternarRastreamento,
                icon: Icon(_rastreando ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _rastreando
                      ? 'Parar Rastreamento'
                      : 'Iniciar Rastreamento Contínuo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
