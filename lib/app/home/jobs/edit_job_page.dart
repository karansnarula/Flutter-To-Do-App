import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/home/models/job.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/database.dart';

class EditJobPage extends StatefulWidget {
  const EditJobPage({Key? key, required this.database, this.job})
      : super(key: key);
  final Database database;
  final Job? job;

  static Future<void> show(BuildContext context, {Job? job}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditJobPage(
        database: database,
        job: job,
      ),
      fullscreenDialog: true,
    ));
  }

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  int? _ratePerHour;
  final FocusNode _jobNameFocusNode = FocusNode();
  final FocusNode _ratePerHourFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      print("Not null");
      _name = widget.job!.name;
      _ratePerHour = widget.job!.ratePerHour;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final jobs = await widget.database
            .jobStream()
            .first; //get the most up-to date list of jobs
        final allNames = jobs.map((job) => job.name).toList();
        if (widget.job != null) {
          allNames.remove(widget.job!.name);
        }
        if (allNames.contains(_name)) {
          showAlertDialog(context,
              title: 'Name already exists',
              content: 'Please choose a different name',
              defaultActionText: 'OK');
        } else {
          final id = widget.job?.id ?? documentIdFromCurrentDate();
          final job = Job(
            id: id,
            name: _name!,
            ratePerHour: _ratePerHour!,
          );
          await widget.database.setJob(job);
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: 'Operation failed', exception: e);
      }
    }
  }

  @override
  void dispose() {
    _jobNameFocusNode.dispose();
    _ratePerHourFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 2.0,
          title: Text(widget.job == null ? 'New Job' : 'Edit Job'),
          actions: <Widget>[
            FlatButton(
                onPressed: _submit,
                child: Text('Save',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    )))
          ]),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormChildren(),
        ));
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        initialValue: _name,
        decoration: InputDecoration(labelText: 'Job name'),
        validator: (value) => value!.isNotEmpty ? null : "Name can't be empty",
        onSaved: (value) => _name = value!,
        focusNode: _jobNameFocusNode,
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_ratePerHourFocusNode),
      ),
      TextFormField(
        initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        decoration: InputDecoration(labelText: 'Rate per hour'),
        keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: false),
        onSaved: (value) => _ratePerHour = int.tryParse(value!) ?? 0,
        focusNode: _ratePerHourFocusNode,
      )
    ];
  }
}
