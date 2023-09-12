import 'package:flutter/material.dart';
import 'package:nf_flutter_undo/src/command/basic_command.dart';
import 'package:nf_flutter_undo/src/undo/inherited_undo.dart';

class UndoView extends StatefulWidget {
  const UndoView({super.key});
  static const String routeName = "UndoTest";

  @override
  State<UndoView> createState() => _UndoViewState();
}

class _UndoViewState extends State<UndoView> {
  List<String> values = [];
  int pc = 0;

  @override
  void initState() {
    super.initState();
    print("Some test text here");
  }

  void undo() {
    InheritedUndo.of(context).undoStack.undo();
  }

  void redo() {
    InheritedUndo.of(context).undoStack.redo();
  }

  void reset() {
    InheritedUndo.of(context).undoStack.clearHistory();
    setState(() => values.clear());
  }

  void add() {
    const String chars = "abcdefghijklmnopqrstuvwxyz";
    String c = chars[pc % chars.length];
    pc += 1;
    BasicCommand bc = BasicCommand(
      commandName: "Add '$c'",
      execute: () {
        setState(() => values.add(c));
      },
      canExecute: () => true,
      canUnexecute: () => values.isNotEmpty,
      unexecute: () {
        setState(() => values.removeLast());
      },
    );
    InheritedUndo.of(context).undoStack.pushCommand(bc);
    bc.execute();
  }

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        Row(
          children: [
            ElevatedButton(onPressed: undo, child: Text("Undo")),
            ElevatedButton(onPressed: redo, child: Text("Redo")),
            ElevatedButton(onPressed: add, child: Text("+")),
            ElevatedButton(onPressed: reset, child: Text("reset")),
          ],
        ),
        Row(
          children: [
            for (final val in values) Text("$val "),
          ],
        ),
        Column(
          children: [
            Text("Stack Info"),
            Text("Stack Pointer: ${InheritedUndo.of(context).undoStack.stackPointer}"),
            Text("Stack Length (undoable): ${InheritedUndo.of(context).undoStack.stackSize}"),
            Text("Can Undo: ${InheritedUndo.of(context).undoStack.canUndo}"),
            Text("Can Redo: ${InheritedUndo.of(context).undoStack.canRedo}"),
            Row(
              children: [
                Text("["),
                for (final c in InheritedUndo.of(context).undoStack.listCommands()) Text("${c.command.commandName}, "),
                Text("]"),
              ],
            )
          ],
        ),
      ],
    ));
  }
}
