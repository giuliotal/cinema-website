import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {

  final String defaultValue;
  final Icon icon;
  final List<String> options;
  final Function refreshPageable;

  const CustomDropdownButton({Key key, this.options, this.defaultValue, this.icon, this.refreshPageable}) : super(key: key);

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {

  String value;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: Theme.of(context).accentColor,
      value: value,
      icon: widget.icon,
      iconSize: 24,
      elevation: 16,
      style: Theme.of(context).textTheme.bodyText1,
      underline: Container(
        height: 2,
        color: Theme.of(context).accentColor,
      ),
      onChanged: (String newValue) {
        setState(() {
          value = newValue;
        });
      },
      items: widget.options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
          onTap: () => widget.refreshPageable(value) //TODO cambiare lo stato della user page (i filtri per la paginazione)
        );
      }).toList(),
    );
  }
}
