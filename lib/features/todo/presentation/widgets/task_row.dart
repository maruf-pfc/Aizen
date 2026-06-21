import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/tag.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import 'subtask_list.dart';

class TaskRow extends StatelessWidget {
  final Task task;

  const TaskRow({super.key, required this.task});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFFF5252); // Red
      case 2:
        return const Color(0xFFFFAB40); // Amber
      case 3:
        return const Color(0xFF40C4FF); // Blue
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final todoBloc = context.read<TodoBloc>();
    final titleController = TextEditingController(text: task.title);
    int selectedPriority = task.priority;
    DateTime? selectedDueDate = task.dueDate;
    final tagsController = TextEditingController(
      text: task.tags.map((t) => t.name).join(', '),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0C0C0C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              title: const Text(
                'Edit Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7C4DFF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        color: Color(0x66FFFFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1, 2, 3, 4].map((p) {
                        final isSelected = selectedPriority == p;
                        Color pColor = const Color(0xFFE0E0E0);
                        if (p == 1) pColor = const Color(0xFFFF5252);
                        if (p == 2) pColor = const Color(0xFFFFAB40);
                        if (p == 3) pColor = const Color(0xFF40C4FF);

                        return ChoiceChip(
                          label: Text('P$p'),
                          selected: isSelected,
                          selectedColor: pColor.withValues(alpha: 0.2),
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: isSelected ? pColor : Colors.white.withValues(alpha: 0.1),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? pColor : Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                selectedPriority = p;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Due Date & Time',
                      style: TextStyle(
                        color: Color(0x66FFFFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDueDate != null
                                ? '${selectedDueDate!.month}/${selectedDueDate!.day} ${selectedDueDate!.hour.toString().padLeft(2, '0')}:${selectedDueDate!.minute.toString().padLeft(2, '0')}'
                                : 'No time set',
                            style: TextStyle(
                              color: selectedDueDate != null ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.redAccent, size: 16),
                            onPressed: () {
                              setState(() {
                                selectedDueDate = null;
                              });
                            },
                          ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF7C4DFF),
                                      onPrimary: Colors.black,
                                      surface: Color(0xFF0C0C0C),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate == null) return;

                            if (!context.mounted) return;

                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDueDate ?? DateTime.now()),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF7C4DFF),
                                      onPrimary: Colors.black,
                                      surface: Color(0xFF0C0C0C),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedTime == null) return;

                            setState(() {
                              selectedDueDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          },
                          child: Text(
                            selectedDueDate != null ? 'Change' : 'Set Time',
                            style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tagsController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Tags (comma separated)',
                        labelStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7C4DFF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      final List<Tag> tagsList = tagsController.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .map((s) => Tag(s))
                          .toList();

                      final updatedTask = task.copyWith(
                        title: title,
                        priority: selectedPriority,
                        dueDate: selectedDueDate,
                        tags: tagsList,
                      );

                      todoBloc.add(UpdateTodoEvent(updatedTask));
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Color(0xFF7C4DFF))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Dismissible(
      key: Key('task_dismiss_${task.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: const Color(0xFF00E676).withValues(alpha: 0.15),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.check, color: Color(0xFF00E676), size: 20),
      ),
      secondaryBackground: Container(
        color: const Color(0xFFFF5252).withValues(alpha: 0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          context.read<TodoBloc>().add(ToggleTodoEvent(task.id));
          return false;
        } else if (direction == DismissDirection.endToStart) {
          context.read<TodoBloc>().add(DeleteTodoEvent(task.id));
          return true;
        }
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: priorityColor,
                  width: 3,
                ),
                top: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
                right: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: const Color(0xFF7C4DFF),
                    checkColor: Colors.black,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) {
                      context.read<TodoBloc>().add(ToggleTodoEvent(task.id));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _showEditTaskDialog(context, task),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          if (task.tags.isNotEmpty || task.dueDate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (task.dueDate != null) ...[
                                  Icon(
                                    Icons.calendar_today,
                                    color: task.isCompleted
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : const Color(0xFF00E676),
                                    size: 10,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.dueDate!.month}/${task.dueDate!.day} ${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: task.isCompleted
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : const Color(0xFF00E676),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (task.tags.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                                ...task.tags.map((tag) => Padding(
                                      padding: const EdgeInsets.only(right: 6.0),
                                      child: Text(
                                        '#${tag.name}',
                                        style: TextStyle(
                                          color: task.isCompleted
                                              ? Colors.white.withValues(alpha: 0.15)
                                              : const Color(0xFF7C4DFF),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 16,
                  ),
                  onPressed: () => _showEditTaskDialog(context, task),
                ),
              ],
            ),
          ),
          SubtaskList(task: task),
        ],
      ),
    );
  }
}
