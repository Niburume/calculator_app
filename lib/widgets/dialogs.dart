import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/result_model.dart';
import '../models/settings_provider.dart';
import 'dialog_screen_tile.dart';

class RenameDialog extends StatelessWidget {
  BuildContext context;
  bool isSession;
  String currentSessionId;
  String? expressionId;
  VoidCallback callback;
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
    final TextEditingController nameControllerTextField =
        TextEditingController();
    final TextEditingController noteControllerTextField =
        TextEditingController();
    final theme =
        Provider.of<SettingsProvider>(context, listen: false).providerTheme;

    SessionModel sessionModel = Provider.of<Results>(context, listen: false)
        .fetchSessionModelById(currentSessionId);
    if (expressionId != null) {
      resultModel = Provider.of<Results>(context, listen: false)
          .fetchResultModelById(currentSessionId, expressionId!);
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
                          textController: nameControllerTextField,
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
                                    .updateSessionName(currentSessionId,
                                        nameControllerTextField.text);
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
                          textController: nameControllerTextField,
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
                              controller: noteControllerTextField,
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
                                noteControllerTextField.text = '';
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
                                if (nameControllerTextField.text.isNotEmpty &&
                                    nameControllerTextField.text !=
                                        'type a name') {
                                  Provider.of<Results>(context, listen: false)
                                      .changeExpressionNameById(
                                          currentSessionId,
                                          resultModel!.id,
                                          nameControllerTextField.text);
                                }
                                if (noteControllerTextField.text.isNotEmpty) {
                                  if (noteControllerTextField.text.isNotEmpty) {
                                    Provider.of<Results>(context, listen: false)
                                        .changeNoteById(
                                            currentSessionId,
                                            resultModel!.id,
                                            noteControllerTextField.text);
                                  }
                                }
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
  TextEditingController textController;
  String hintText;

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
