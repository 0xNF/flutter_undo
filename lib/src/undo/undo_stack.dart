import 'package:flutter_undo/src/command/command.dart';
import 'package:flutter_undo/src/command/command_history.dart';
import 'package:flutter_undo/src/logger.dart';

class UndoStack {
  /// Maximium amount of elements allowed to be in the history stack
  ///
  /// Must be a positive integer
  ///
  /// Larger values mean the program will directly consume more memory by storing more undo states in ram
  final int maxStackSize;

  /// Pointer to where in the Undo Stack the user has undone to.
  ///
  /// This pointer is used to permit Redo functionality
  ///
  /// A command can be "Undoes", at which point the stackPointer is adjusted by +1
  /// The command's "unexecute()" function is run, but not actually removed from the stack, however
  ///
  /// If a user "Redoes" the command, the stackPointer is adjusted by -1
  /// The command's "execute()" function is run, but nothing is pushed onto the stack
  ///
  /// If a user "Undoes" a command, but then adds a new command, the stackPointer is set to '0' and redoes are no longer permitted
  int stackPointer = -1;

  /// List of command objects executed by the user
  final List<CommandHistory> _stack = [];

  /// Current number of undoable elements in the stack
  int get stackSize => _stack.length - stackPointer;

  bool get canUndo => stackPointer > -1 && stackPointer < _stack.length;
  bool get canRedo => stackPointer > 0; /* -1 (empty) and 0 (no future objects) mean cannot go forwards */

  UndoStack({this.maxStackSize = 64}) : assert(maxStackSize > 0, "stackSize must be a positive integer > 0");

  /// Adds this command to the stack. The time of execution is recorded within the command.
  ///
  /// Adding to the stack does not imply an execution -- you are responsible for calling `execute()` on your own, either before or after adding to the stack
  void pushCommand(ICommand command) {
    logger.info("pushing command to undo stack");
    final CommandHistory ch = CommandHistory(command: command);
    /* Push the command to the stack, removing the least recent command if stack is too big */
    if (_stack.length == maxStackSize) {
      logger.trace("undo stack size exceeded, removing lru entry");
      _stack.removeAt(maxStackSize - 1);
    }
    if (stackPointer > 0) {
      /* if stackPointer is greater than zero but we've gotten a push request, then the user has unwound the undo stack but added a new command ontop of it, invalidating all future commands
      * In response, we must eliminate everything in the stack before the pointer: the state can no longer be consistent if we keep those commands around
      * fyi(nf, 22/6/19): UndoTrees can be implemented at this stage in the future, if required
      */
      logger.trace("undo stack rewound and then appended to. Invalidating all future saved sates");
      _stack.removeRange(0, stackPointer);
    }
    _stack.insert(0, ch);
    stackPointer = 0;
  }

  /// Undoes the most recent command that can be undone
  ///
  /// If the command cannot be undone, it is removed from the list and searching continues until:
  ///   * the list is empty
  ///   * an undoable element is found
  ///
  /// Returns the [CommandHistory] object that was undone, or [null] if nothing was undone
  CommandHistory? undo() {
    if (!canUndo) {
      return null;
    }
    CommandHistory? ch = peekCurrent();
    if (ch == null) {
      return null;
    }

    logger.info("Undoing command");

    /* move the stackPointer up by one to represent a pop */
    stackPointer += 1;

    /* always remove the command from the list */
    // _stack.removeAt(0);
    if (ch.command.canUnexecute()) {
      /* call the unexecute command */
      ch.command.unexecute?.call();
      return ch;
    } else {
      /* if un-executable, keep searching for one that is */
      return undo();
    }
  }

  /// Redoes the command at the head of the stack
  CommandHistory? redo() {
    if (!canRedo) {
      return null;
    }
    final ch = peekForward();
    if (ch == null) {
      return null;
    }

    if (ch.command.canExecute()) {
      logger.info("Redoing command");
      /* move the stackPointer down by one to represent a push */
      stackPointer -= 1;
      ch.command.execute();
      return ch;
    } else {
      /* If the commmand canot be executed, and thus cannot be redone, return null */
      return null;
    }
  }

  /// Returns the most recently applied command
  ///
  /// Caution: Do not execute or unExecute the command returned by this method, otherwise the UndoStack will lose track of state consistency
  CommandHistory? peekCurrent() {
    if (_stack.isEmpty) {
      return null;
    } else if (stackPointer >= _stack.length) {
      return _stack.last;
    } else {
      return _stack[stackPointer];
    }
  }

  /// Returns the most recently undone command
  ///
  /// Caution: Do not execute or unExecute the command returned by this method, otherwise the UndoStack will lose track of state consistency
  CommandHistory? peekForward() {
    if (_stack.isEmpty) {
      return null;
    } else if (stackPointer < 0) {
      return null;
    } else {
      return _stack[stackPointer - 1];
    }
  }

  /// returns an unmodifable list view of the current Command Stack
  List<CommandHistory> listCommands() {
    return List.unmodifiable(_stack);
  }

  /// Empties the current history. This action is not undoable.
  void clearHistory() {
    logger.debug("Clearing undo stack");
    _stack.clear();
    stackPointer = 0;
  }
}
