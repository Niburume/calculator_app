import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/settings_provider.dart';
import 'dialog_screen_tile.dart';

class RenameDialog extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final BuildContext context;
  final bool isSession;
  final int currentSessionId;
  final int? expressionId;
  final VoidCallback callback;
  RenameDialog(
      {required this.context,
      required this.isSession,
      required this.currentSessionId,
      this.expressionId,
      required this.callback});
//
//   @override
//   State<RenameDialog> createState() => _RenameDialogState();
// }

// class _RenameDialogState extends State<RenameDialog> {
  @override
  Widget build(BuildContext context) {
    ResultModel? resultModel;

    final theme =
        Provider.of<SettingsProvider>(context, listen: false).providerTheme;

    SessionModel sessionModel = Provider.of<Results>(context, listen: false)
        .fetchSessionModelById(currentSessionId);
    if (expressionId != null) {
      resultModel = Provider.of<Results>(context, listen: false)
          .fetchResultModelById(currentSessionId, expressionId!);
    }
    if (resultModel?.note != null) {
      noteController.text = resultModel!.note!;
    }
    return isSession
        ? Dialog(
            backgroundColor: theme.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)), //this right here
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 400,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DialogTile(
                        label: 'Date:',
                        value: DateFormat('yyyy/MM/dd HH:mm')
                            .format(sessionModel.dateStamp)
                            .toString(),
                      ),
                      CustomTextField(
                          textController: nameController,
                          hintText: sessionModel.sessionName!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.resultText,
                                backgroundColor:
                                    theme.clearButton, // foreground
                              ),
                              onPressed: () {
                                callback();
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.resultText,
                                backgroundColor:
                                    theme.operationButton, // foreground
                              ),
                              onPressed: () {
                                Provider.of<Results>(context, listen: false)
                                    .updateSession(currentSessionId,
                                        nameController.text, null);
                                callback();
                                Navigator.pop(context);
                              },
                              child: Text('Save'),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        : Dialog(
            backgroundColor: theme.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)), //this right here
            child: SingleChildScrollView(
              child: Container(
                // constraints: const BoxConstraints(maxHeight: 400),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DialogTile(
                        label: 'Date:',
                        value: DateFormat('yyyy/MM/dd HH:mm')
                            .format(resultModel!.dateStamp)
                            .toString(),
                      ),
                      DialogTile(
                        label: 'Adress:',
                        value: 'Lillhagsvägen 8, 124 71 Bandhagen',
                      ),
                      CustomTextField(
                          textController: nameController,
                          hintText: resultModel.name == null
                              ? 'type a name'
                              : resultModel.name!),
                      const Divider(
                        thickness: 1,
                      ),
                      DialogTile(
                        label: 'Expression:',
                        value: resultModel.expression,
                      ),
                      DialogTile(
                        label: 'RESULT:',
                        value: resultModel.result.toString(),
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      Stack(children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: theme.background,
                            // border: Border.all(color: theme.historyText),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: SingleChildScrollView(
                            child: TextField(
                              style: TextStyle(color: theme.resultText),
                              maxLines: 3,
                              controller: noteController,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: resultModel.note == null
                                          ? theme.historyText
                                          : theme.resultText),
                                  border: InputBorder.none,
                                  hintText: resultModel.note ??
                                      'type a note here...'),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 15,
                              icon: const Icon(Icons.clear),
                              color: theme.historyText,
                              onPressed: () {
                                noteController.text = '';
                              },
                            ),
                          ),
                        ),
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.resultText,
                                backgroundColor:
                                    theme.clearButton, // foreground
                              ),
                              onPressed: () {
                                callback();
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.resultText,
                                backgroundColor:
                                    theme.operationButton, // foreground
                              ),
                              onPressed: () {
                                String name = '';
                                String? note = '';

                                // if (nameController.text != name &&
                                //     name != '...') {
                                //   nameController.text.isEmpty
                                //       ? name = '...'
                                //       : name = nameController.text;
                                // }
                                if (nameController.text.isNotEmpty &&
                                    nameController.text != 'type a name') {
                                  name = nameController.text;
                                } else {
                                  name = '...';
                                }

                                if (noteController.text.isNotEmpty) {
                                  note = noteController.text;
                                }
                                Provider.of<Results>(context, listen: false)
                                    .updateResult(currentSessionId,
                                        resultModel!.id, name, note);

                                callback();
                                Navigator.pop(context);
                              },
                              child: Text('Save'),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController textController;
  final String hintText;

  CustomTextField({required this.textController, required this.hintText});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<SettingsProvider>(context, listen: false).providerTheme;
    widget.textController.text = widget.hintText;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Name: ',
          style: TextStyle(color: theme.historyText),
        ),
        Expanded(
          child: TextField(
            style: TextStyle(color: theme.resultText),
            controller: widget.textController,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: theme.resultText),
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(
          height: 20,
          width: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 15,
            icon: const Icon(Icons.clear),
            color: theme.historyText,
            onPressed: () {
              widget.textController.text = '';
            },
          ),
        )
      ],
    );
  }
}
