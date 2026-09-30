import 'package:flutter/material.dart';
import '../../../lockscreen_verses/data/root_access_service.dart';

class RootAccessPermissionDialog extends StatefulWidget {
  final VoidCallback onGranted;
  final VoidCallback onDenied;

  const RootAccessPermissionDialog({
    super.key,
    required this.onGranted,
    required this.onDenied,
  });

  @override
  State<RootAccessPermissionDialog> createState() =>
      _RootAccessPermissionDialogState();
}

class _RootAccessPermissionDialogState extends State<RootAccessPermissionDialog> {
  bool _isChecking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndRequestRoot();
  }

  Future<void> _checkAndRequestRoot() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final isRooted = await RootAccessService.isRooted();
      if (!isRooted) {
        final granted = await RootAccessService.requestRoot();
        if (granted) {
          widget.onGranted();
          if (mounted) Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = 'Root access was denied';
          });
        }
      } else {
        widget.onGranted();
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error requesting root access: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Root Access Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To display dynamic lock screen verses on every lock/unlock, this app needs root access to:',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Change lock screen wallpaper instantly'),
                Text('• Listen to device lock/unlock events'),
                Text('• Cache wallpapers on system partition'),
                Text('• Enable seamless verse rotation'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[900]),
              ),
            ),
          if (_isChecking)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isChecking
              ? null
              : () {
                  widget.onDenied();
                  Navigator.pop(context, false);
                },
          child: const Text('Cancel'),
        ),
        if (_errorMessage != null)
          TextButton(
            onPressed: _isChecking ? null : _checkAndRequestRoot,
            child: const Text('Retry'),
          ),
      ],
    );
  }
}

class RootAccessScreen extends StatefulWidget {
  const RootAccessScreen({super.key});

  @override
  State<RootAccessScreen> createState() => _RootAccessScreenState();
}

class _RootAccessScreenState extends State<RootAccessScreen> {
  bool? _isRooted;
  bool _requestingAccess = false;

  @override
  void initState() {
    super.initState();
    _checkRooted();
  }

  Future<void> _checkRooted() async {
    final rooted = await RootAccessService.isRooted();
    setState(() {
      _isRooted = rooted;
    });
  }

  Future<void> _requestAccess() async {
    setState(() => _requestingAccess = true);

    final granted = await RootAccessService.requestRoot();
    if (granted) {
      _checkRooted();
    }

    setState(() => _requestingAccess = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(granted ? 'Root access granted' : 'Root access denied'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Root Access')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isRooted == true ? Icons.check_circle : Icons.cancel,
                        color: _isRooted == true ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Root Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isRooted == null
                                ? 'Checking...'
                                : _isRooted == true
                                    ? 'Device is rooted'
                                    : 'Device is not rooted',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What Root Access Enables:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            'Instant lock screen wallpaper rotation on every unlock',
            'Listen to device lock/unlock events directly',
            'Bypass standard wallpaper restrictions',
            'Cache wallpapers system-wide',
            'Enable continuous verse rotation without battery drain',
          ].map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check, size: 20, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(child: Text(feature)),
              ],
            ),
          )),
          const SizedBox(height: 32),
          if (_isRooted != true)
            Column(
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This will prompt you to grant root access through your rooting manager (Magisk, SuperSU, etc.)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _requestingAccess ? null : _requestAccess,
                  icon: const Icon(Icons.security),
                  label: const Text('Request Root Access'),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Root access is enabled. Lock screen verses will rotate on every unlock.',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
