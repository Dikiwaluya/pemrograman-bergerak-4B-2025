import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    Connectivity().onConnectivityChanged.listen((status) {
      final hasConnection = status != ConnectivityResult.none;
      if (hasConnection != isConnected) {
        setState(() => isConnected = hasConnection);
        _showSnackbar(hasConnection);
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final status = await Connectivity().checkConnectivity();
    final hasConnection = status != ConnectivityResult.none;
    setState(() => isConnected = hasConnection);

    if (!hasConnection) _showSnackbar(false);
  }

  void _showSnackbar(bool hasConnection) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (!hasConnection) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text("Tidak ada koneksi internet"),
          action: SnackBarAction(
            label: "Coba Lagi",
            onPressed: _checkInitialConnection,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Koneksi internet tersedia"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
