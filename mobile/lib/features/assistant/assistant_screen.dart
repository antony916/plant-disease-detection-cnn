import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/navigation/app_router.dart';
import '../../core/services/plant_assistant_service.dart';
import '../../core/theme/app_theme.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final controller = TextEditingController();
  final List<_Message> messages = <_Message>[];
  bool isSending = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty || isSending) return;

    setState(() {
      messages.add(_Message(text: text, fromUser: true));
      isSending = true;
    });
    controller.clear();

    try {
      final plants = await AppServices.garden.getPlants();
      final reply = await PlantAssistantService(AppServices.care).answer(
        question: text,
        plants: plants,
      );
      if (!mounted) return;
      setState(() {
        messages.add(_Message(text: reply.message, fromUser: false));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add(
          const _Message(
            text:
                'I could not load your garden context right now. Please try again.',
            fromUser: false,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  void _usePrompt(String prompt) {
    controller.text = prompt;
    _send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PlantCare AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(PlantCareSpacing.lg),
              children: [
                for (final message in messages)
                  _MessageBubble(message: message),
                if (isSending)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(PlantCareSpacing.md),
                  decoration: BoxDecoration(
                    color: PlantCareColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Hi! Ask me about watering, plant care, symptoms, pests or your garden. I will use your saved garden context when the production backend is connected.',
                  ),
                ),
                const SizedBox(height: PlantCareSpacing.md),
                const Text(
                  'Try asking:',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: PlantCareSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Why are my tomato leaves yellow?'),
                      onPressed: () =>
                          _usePrompt('Why are my tomato leaves yellow?'),
                    ),
                    ActionChip(
                      label: const Text('What should I water today?'),
                      onPressed: () => _usePrompt('What should I water today?'),
                    ),
                    ActionChip(
                      label: const Text('Help me identify this pest'),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.scanner),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PlantCareSpacing.md,
                8,
                PlantCareSpacing.md,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask PlantCare AI...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: isSending ? null : _send,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 3),
    );
  }
}

class _Message {
  final String text;
  final bool fromUser;

  const _Message({required this.text, required this.fromUser});
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 330),
        decoration: BoxDecoration(
          color: message.fromUser
              ? PlantCareColors.primary
              : PlantCareColors.card,
          borderRadius: BorderRadius.circular(14),
          border: message.fromUser
              ? null
              : Border.all(color: PlantCareColors.border),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.fromUser ? Colors.white : PlantCareColors.text,
          ),
        ),
      ),
    );
  }
}
