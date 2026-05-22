import 'package:flutter/material.dart';
import '../utils/sri_lanka_regions.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _inputController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  String _selectedProvince = 'Western';
  String _selectedDistrict = 'Colombo';
  String _selectedCity = 'Colombo';

  final List<String> _quickActions = const [
    'Find hospitals in Colombo',
    'Recommend a cardiology center in Kandy',
    'What should I do for chest pain?',
    'Show medical centers near me',
  ];

  @override
  void initState() {
    super.initState();
    // Add initial assistant greeting
    _messages.add(
      ChatMessage(
        text: 'Hello! I am your CardioSense assistant. Ask me for Sri Lanka hospital locations, medical center recommendations, or cardiology care guidance.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
    });

    final botReply = _getBotResponse(text.trim(), _selectedCity);
    
    // Tiny delay to simulate AI thinking
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: botReply, isUser: false));
        });
        _scrollToBottom();
      }
    });

    _inputController.clear();
    _scrollToBottom();
  }

  String _getBotResponse(String message, String city) {
    final query = message.toLowerCase();
    
    // Detect custom cities in query
    String activeCity = city;
    for (var key in SriLankaRegions.locationCenters.keys) {
      if (query.contains(key.toLowerCase())) {
        activeCity = key;
        break;
      }
    }

    if (query.contains('hospital') ||
        query.contains('medical center') ||
        query.contains('clinic') ||
        query.contains('emergency') ||
        query.contains('location') ||
        query.contains('sri lanka')) {
      
      final centers = SriLankaRegions.locationCenters[activeCity];
      if (centers == null) {
        // Fallback to Colombo
        final colomboCenters = SriLankaRegions.locationCenters['Colombo']!;
        return 'I don\'t have specific hospital records for $activeCity, but here are trusted centers in Colombo, Sri Lanka:\n\n'
            '${colomboCenters.map((c) => '• ${c.name} – ${c.address} (Tel: ${c.phone})').join('\n\n')}\n\n'
            'Please call ahead to confirm availability and seek emergency services if experiencing symptoms.';
      }

      return 'Here are trusted hospitals and cardiology clinics in $activeCity, Sri Lanka:\n\n'
          '${centers.map((c) => '• ${c.name} – ${c.address} (Tel: ${c.phone})').join('\n\n')}\n\n'
          'Please call ahead to confirm availability and let them know if you have chest pain or breathlessness.';
    }

    if (query.contains('recommendation') ||
        query.contains('advice') ||
        query.contains('suggestion') ||
        query.contains('plan') ||
        query.contains('treatment')) {
      return 'I can provide primary cardiac suggestions for Sri Lanka patients:\n\n'
          '• Monitor your heart rate and blood pressure daily.\n'
          '• Limit excessive salt, caffeine, and heavy activities.\n'
          '• Log symptoms (e.g. breathlessness, dizziness, chest discomfort).\n\n'
          'Warning: If chest pain worsens or radiates to your arm, seek emergency care immediately at the closest hospital.';
    }

    if (query.contains('heart') ||
        query.contains('cardio') ||
        query.contains('rhythm') ||
        query.contains('afib') ||
        query.contains('arrhythmia') ||
        query.contains('stroke')) {
      return 'For irregular heart rhythms or Atrial Fibrillation concerns:\n\n'
          '• Coordinate a cardiac evaluation at a hospital in $activeCity.\n'
          '• Take your ECG reports and medication histories to your appointments.\n'
          '• Follow clinical guidelines and dosage schedules strictly.\n\n'
          'If you experience sudden fluttering, fainting, or chest pressure, consult emergency specialists.';
    }

    return 'I\'m here to support you with recommendations and Sri Lanka care location guidance.\n'
        'Please ask about hospitals, clinics, cardiology advice, or patient support, and I will help as best as I can.';
  }

  @override
  Widget build(BuildContext context) {
    final provinces = SriLankaRegions.regions.keys.toList();
    final districts = SriLankaRegions.regions[_selectedProvince]?.keys.toList() ?? [];
    final cities = SriLankaRegions.regions[_selectedProvince]?[_selectedDistrict] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: Column(
        children: [
          // Local Geographic Selectors (Collapsible Panel)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ExpansionTile(
              title: Row(
                children: [
                  const Icon(Icons.map_outlined, color: Color(0xFF0A66C2), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Location: $_selectedCity ($_selectedProvince)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                ],
              ),
              dense: true,
              childrenPadding: const EdgeInsets.only(bottom: 10),
              children: [
                Row(
                  children: [
                    // Province
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedProvince,
                        decoration: const InputDecoration(labelText: 'Province', isDense: true),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        items: provinces.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedProvince = val;
                              _selectedDistrict = SriLankaRegions.regions[val]!.keys.first;
                              _selectedCity = SriLankaRegions.regions[val]![_selectedDistrict]!.first;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // District
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: const InputDecoration(labelText: 'District', isDense: true),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDistrict = val;
                              _selectedCity = SriLankaRegions.regions[_selectedProvince]![val]!.first;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // City
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(labelText: 'City', isDense: true),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCity = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Messages View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? const Color(0xFF0A66C2) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(msg.isUser ? 12 : 0),
                        bottomRight: Radius.circular(msg.isUser ? 0 : 12),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : const Color(0xFF1F2937),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggestions grid (quick actions)
          if (_messages.length == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _quickActions.length,
                itemBuilder: (context, idx) {
                  final action = _quickActions[idx];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(action),
                      onPressed: () => _sendMessage(action),
                      backgroundColor: Colors.white,
                      labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                      side: const BorderSide(color: Color(0xFFEBF3FF)),
                    ),
                  );
                },
              ),
            ),

          // Input Bar
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: 'Ask hospital locations or medical plans...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF0A66C2)),
                    onPressed: () => _sendMessage(_inputController.text),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
