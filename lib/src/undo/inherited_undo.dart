import 'package:flutter/widgets.dart';
import 'package:flutter_undo/src/command/command.dart';
import 'package:flutter_undo/src/command/command_history.dart';
import 'package:flutter_undo/src/undo/undo_stack.dart';

/// Widget allowing an [UndoStack] to be applied to all children elements
///
/// Access the undo stack from children via `InheritedUndo.of(context).undoStack`
class InheritedUndo extends InheritedWidget {
  final UndoStack undoStack = UndoStack();
  InheritedUndo({super.key, required super.child});

  @override
  bool updateShouldNotify(InheritedUndo oldWidget) {
    return oldWidget.undoStack.stackSize != undoStack.stackSize;
  }

  void pushCommand(ICommand command) {
    undoStack.pushCommand(command);
  }

  CommandHistory? popCommand() {
    return undoStack.undo();
  }

  static InheritedUndo of(BuildContext context) {
    final InheritedUndo? result =
        context.dependOnInheritedWidgetOfExactType<InheritedUndo>();
    assert(result != null, 'No InheritedUndo found in context');
    return result!;
  }
}
