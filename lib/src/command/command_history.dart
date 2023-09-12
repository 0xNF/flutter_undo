import 'package:nf_flutter_undo/src/command/command.dart';

/// Records a command, along with the time of execution
class CommandHistory {
  final DateTime date = DateTime.now();
  final ICommand command;

  CommandHistory({required this.command});

  @override
  String toString() {
    return "${command.commandName} (${date.toString()})";
  }
}
