/// Abstract class for constructing Command objects, which make Undo/Redo easier
///
/// A correct implementation of a Command object will encapsulate all necessary state for the command to take effect within the `execute()` method.
///
/// It is recommended to also implement the`canExecute()` so that the transforms applies by the object will be valid.
///
/// To implement Redo, place the undo logic into the `unexecute()` method.
///
/// Similarly to execute and canExecute, it is recommended to implement the `canUnexecute()` method as well.
///
/// Leaving these methods blanks defaults to a Command that can be executed forwards, but not backwards.
///
/// A basic implementation of ICommand is provided via [BasicCommand]
abstract class ICommand {
  /// User friendly name of this command
  final String commandName;

  /// Test for whether this command can actually execute or not
  final bool Function() canExecute;

  /// The concrete action this command will invoke. Usually in the form of () { actual_stuff(); }
  final void Function() execute;

  /// Test for whether this command can be undone
  final bool Function() canUnexecute;

  /// The concrete action this command will take to undo the steps of the execute.
  final void Function()? unexecute;

  ICommand({
    required void Function() execute,
    this.commandName = "Anonymous Command",
    this.unexecute,
    bool Function()? canExecute,
    bool Function()? canUnexecute,
  })  : canExecute = (canExecute ?? () => true),
        canUnexecute = (canUnexecute ?? () => false),
        execute = (() {
          if (canExecute != null && canExecute.call()) {
            execute();
          }
        });
}
