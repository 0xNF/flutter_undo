import 'package:nf_flutter_undo/src/command/command.dart';

/// A basic implementation of the [ICommand] interface
class BasicCommand extends ICommand {
  BasicCommand({
    String commandName = "Anonymous Command",
    required execute,
    unexecute,
    bool Function()? canExecute,
    bool Function()? canUnexecute,
  }) : super(
          canExecute: canExecute,
          execute: execute,
          canUnexecute: canUnexecute,
          commandName: commandName,
          unexecute: unexecute,
        );

  @override
  String toString() {
    return "$commandName, hasUnexecute: ${unexecute != null}";
  }
}
