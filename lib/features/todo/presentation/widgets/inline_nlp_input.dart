import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/nlp_parsed_result.dart';
import '../../data/services/nlp_parser_service.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class InlineNlpInput extends StatefulWidget {
  const InlineNlpInput({super.key});

  @override
  State<InlineNlpInput> createState() => _InlineNlpInputState();
}

class _InlineNlpInputState extends State<InlineNlpInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final NlpParserService _parser = const NlpParserService();
  NlpParsedResult? _previewResult;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      setState(() {
        _previewResult = null;
      });
    } else {
      setState(() {
        _previewResult = _parser.parse(text);
      });
    }
  }

  void _submitTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<TodoBloc>().add(AddTodoEvent(text));
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFFF5252); // Red
      case 2:
        return const Color(0xFFFFAB40); // Amber
      case 3:
        return const Color(0xFF40C4FF); // Blue
      default:
        return const Color(0xFFE0E0E0); // Light Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? const Color(0xFF7C4DFF).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.add_task,
                  color: Color(0xFF7C4DFF),
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add task... tomorrow at 5pm !!1 #work',
                    hintStyle: TextStyle(
                      color: Color(0x66FFFFFF),
                      fontSize: 13,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onSubmitted: (_) => _submitTask(),
                  onTap: () {
                    setState(() {}); // refresh border outline
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18, color: Colors.white),
                onPressed: _submitTask,
              ),
            ],
          ),
        ),
        if (_previewResult != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Preview:',
                  style: TextStyle(
                    color: Color(0x66FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_previewResult!.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getPriorityColor(_previewResult!.priority).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'P${_previewResult!.priority}',
                    style: TextStyle(
                      color: _getPriorityColor(_previewResult!.priority),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_previewResult!.dueDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF00E676),
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_previewResult!.dueDate!.month}/${_previewResult!.dueDate!.day} ${_previewResult!.dueDate!.hour.toString().padLeft(2, '0')}:${_previewResult!.dueDate!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ..._previewResult!.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '#${tag.name}',
                        style: const TextStyle(
                          color: Color(0xFF7C4DFF),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
