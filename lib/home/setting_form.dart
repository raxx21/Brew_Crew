import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/constant.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0','1','2','3','4'];

  //formValues
  String _currentName;
  String _currentSugars;
  int _currentStrength;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserFirebase>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          UserData userdata = snapshot.data;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Update your brew settings',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 30.0,),
                  TextFormField(
                    initialValue: userdata.name,
                    decoration: textInputDecorationModel,
                    validator: (val) => val.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() => _currentName = val),
                  ),
                  SizedBox(height: 20.0,),
                  //dropdown
                  DropdownButtonFormField(
                    decoration: textInputDecorationModel,
                    value: _currentSugars ?? userdata.sugars,
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(value : sugar,child: Text('$sugar sugars'));
                    }).toList(),
                    onChanged: (val) => setState(() => _currentSugars = val),
                  ),
                  //slider
                  SizedBox(height: 20.0,),
                  Slider(
                      value: (_currentStrength ?? userdata.strength).toDouble(),
                      activeColor: Colors.brown[_currentStrength ?? 100],
                      inactiveColor: Colors.brown[_currentStrength ?? 100],
                      min: 100.0,
                      max: 900.0,
                      divisions: 8,
                      onChanged: (val) => setState(() => _currentStrength = val.round())
                  ),
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        await DatabaseService(uid: user.uid).updateUserData(
                          _currentSugars ?? userdata.sugars,
                          _currentName ?? userdata.name,
                          _currentStrength ?? userdata.strength
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(height: 20.0,)
                ],
              ),
            ),
          );
        }
        else{
          return LoadingModel();
        }
      }
    );
  }
}
