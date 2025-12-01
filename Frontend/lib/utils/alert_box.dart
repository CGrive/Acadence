import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<void> alertboxBuilder(BuildContext context, {String? whatsclicked}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Dialogue :)'),
      content: Text(
        'You are viewing this because..\n'
        'you clicked ${whatsclicked ?? "Somethings"}',
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

Future<void> dialogueBoxFullbox(BuildContext context, {String? whatsclicked}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => Dialog.fullscreen(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "This is a fullscreen dialog, and you clicked ${whatsclicked ?? 'something'}",
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    ),
  );
}

Future<void> simpleDialogue(BuildContext context, {String? whatsclicked}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text("You are viewing a simple dialogue"),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Close with Option 1"),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Close with Option 2"),
        ),
      ],
    ),
  );
}
