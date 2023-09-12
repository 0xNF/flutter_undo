Flutter package that provides a simple Undo/Redo system based on the Command pattern common to .NET projects.

# Usage

First, add an `InheritedUndo` to your widget tree:

```dart
/// omitted ...
InheritedUndo(
    child: Placeholder(),
)
```

Then create a Command and implement both the `execute` and `unexecute` functions:

```dart
BasicCommand bc = BasicCommand(
    commandName: "<Command Name>'",
    execute: () {
        setState(() => values.add(c));
    },
    canExecute: () => true,
    canUnexecute: () => values.isNotEmpty,
    unexecute: () {
        setState(() => values.removeLast());
    },
);
```

Then add this command to the undo stack and execute it:

```dart
InheritedUndo.of(context).undoStack.pushCommand(bc);
bc.execute();
```

This pushes the command to the `UndoStack` and it can now be popped and pushed.

The UndoStack has the following interface:

```dart

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

  /// Current number of undoable elements in the stack
  int get stackSize;

  bool get canUndo;
  bool get canRedo;

  /// Adds this command to the stack. The time of execution is recorded within the command.
  ///
  /// Adding to the stack does not imply an execution -- you are responsible for calling `execute()` on your own, either before or after adding to the stack
  void pushCommand(ICommand command);

  /// Undoes the most recent command that can be undone
  ///
  /// If the command cannot be undone, it is removed from the list and searching continues until:
  ///   * the list is empty
  ///   * an undoable element is found
  ///
  /// Returns the [CommandHistory] object that was undone, or [null] if nothing was undone
  CommandHistory? undo();

  /// Redoes the command at the head of the stack
  CommandHistory? redo();  

  /// Returns the most recently applied command
  ///
  /// Caution: Do not execute or unExecute the command returned by this method, otherwise the UndoStack will lose track of state consistency
  CommandHistory? peekCurrent();

  /// Returns the most recently undone command
  ///
  /// Caution: Do not execute or unExecute the command returned by this method, otherwise the UndoStack will lose track of state consistency
  CommandHistory? peekForward();

  /// returns an unmodifable list view of the current Command Stack
  List<CommandHistory> listCommands();

  /// Empties the current history. This action is not undoable.
  void clearHistory();
}

```


# Contributing
If you're interested in contributing to this repository, check out the repo at https://github.com/0xnf/flutter_undo