import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputView extends StatefulWidget {
  final Future<bool> Function(String) onVerified;
  final String description;
  final int pinLength;

  const PinInputView({
    super.key,
    required this.onVerified,
    this.description = 'Enter PIN',
    this.pinLength = 4,
  });

  @override
  State<PinInputView> createState() => _PinInputViewState();
}

class _PinInputViewState extends State<PinInputView> {
  String _currentPin = '';
  bool _isError = false;

  void _onKeyPress(String value) {
    if (_currentPin.length < widget.pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentPin += value;
        _isError = false;
      });

      if (_currentPin.length == widget.pinLength) {
        _verify();
      }
    }
  }

  void _onDelete() {
    if (_currentPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verify() async {
    final success = await widget.onVerified(_currentPin);
    if (success) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _currentPin = '';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.pinLength,
                (index) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isError
                        ? Colors.red
                        : (index < _currentPin.length
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]),
                  ),
                ),
              ),
            ),
            const Spacer(),
            _buildNumberPad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var j = 1; j <= 3; j++)
                _buildNumberButton((i * 3 + j).toString()),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Placeholder for alignment
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String value) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(value),
        customBorder: const CircleBorder(),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onDelete,
        customBorder: const CircleBorder(),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: const Icon(Icons.backspace_outlined),
        ),
      ),
    );
  }
}
