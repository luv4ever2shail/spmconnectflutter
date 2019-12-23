import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spmconnectapp/models/report.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final TextEditingController controller;
  final Report report;
  final FocusNode focusNode;
  final ValueChanged<T> onChanged;
  final T value;
  final TextStyle style;
  final Widget searchHint;
  final Widget hint;
  final Widget disabledHint;
  final Widget icon;
  final Color iconEnabledColor;
  final Color iconDisabledColor;
  final double iconSize;
  final bool isExpanded;
  final bool isCaseSensitiveSearch;

  SearchableDropdown(
      {Key key,
      @required this.items,
      @required this.onChanged,
      this.controller,
      this.focusNode,
      this.report,
      this.value,
      this.style,
      this.searchHint,
      this.hint,
      this.disabledHint,
      this.icon,
      this.iconEnabledColor,
      this.iconDisabledColor,
      this.iconSize = 24.0,
      this.isExpanded = false,
      this.isCaseSensitiveSearch = false})
      : assert(items != null),
        assert(iconSize != null),
        assert(isExpanded != null),
        super(key: key);

  @override
  _SearchableDropdownState<T> createState() => new _SearchableDropdownState();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  TextStyle get _textStyle => widget.style ?? Theme.of(context).textTheme.title;

  bool enabled = false;
  bool get _enabled =>
      widget.items != null &&
      widget.items.isNotEmpty &&
      widget.onChanged != null;

  Icon defaultIcon = Icon(Icons.arrow_drop_down);

  void _updateSelectedIndex() {
    if (!_enabled) {
      return;
    }

    assert(widget.value == null ||
        widget.items
                .where((DropdownMenuItem<T> item) => item.value == widget.value)
                .length ==
            1);
  }

  @override
  void initState() {
    _updateSelectedIndex();
    super.initState();
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items =
        _enabled ? List<Widget>.from(widget.items) : <Widget>[];

    if (widget.hint != null || (!_enabled && widget.disabledHint != null)) {
      final Widget emplacedHint = _enabled
          ? widget.hint
          : DropdownMenuItem<Widget>(child: widget.disabledHint ?? widget.hint);

      items.add(DefaultTextStyle(
        style: _textStyle.copyWith(color: Theme.of(context).hintColor),
        child: IgnorePointer(
          child: emplacedHint,
          ignoringSemantics: false,
        ),
      ));
    }

    Widget result = new InkWell(
      onLongPress: () {
        setState(() {
          enabled = true;
        });
      },
      onTap: () async {
        T value = await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return new DropdownDialog(
                  items: widget.items,
                  hint: widget.searchHint,
                  isCaseSensitiveSearch: widget.isCaseSensitiveSearch);
            });
        if (widget.onChanged != null && value != null) {
          widget.controller.text = value.toString();
          widget.report.getcustomer = value.toString();
          widget.onChanged(value);
        }
      },
      child: TextField(
          inputFormatters: [
            new BlacklistingTextInputFormatter(new RegExp(
                '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
          ],
          focusNode: widget.focusNode,
          style: _textStyle,
          controller: widget.controller,
          onChanged: (val) {
            widget.report.getcustomer = val;
          },
          enabled: enabled,
          decoration: InputDecoration(
              hintText: 'Select customer from suggestions',
              labelText: 'Customer',
              suffixIcon: defaultIcon,
              labelStyle: _textStyle,
              border: OutlineInputBorder())),
    );

    return new Stack(
      children: <Widget>[
        result,
      ],
    );
  }
}

class DropdownDialog<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Widget hint;
  final bool isCaseSensitiveSearch;

  DropdownDialog(
      {Key key, this.items, this.hint, this.isCaseSensitiveSearch = false})
      : assert(items != null),
        super(key: key);

  _DropdownDialogState createState() => new _DropdownDialogState();
}

class _DropdownDialogState extends State<DropdownDialog> {
  TextEditingController txtSearch = new TextEditingController();
  TextStyle defaultButtonStyle =
      new TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  List<int> shownIndexes = [];

  void _updateShownIndexes(String keyword) {
    shownIndexes.clear();
    int i = 0;
    widget.items.forEach((item) {
      bool isContains = false;
      if (widget.isCaseSensitiveSearch) {
        isContains = item.value.toString().contains(keyword);
      } else {
        isContains =
            item.value.toString().toLowerCase().contains(keyword.toLowerCase());
      }
      if (keyword.isEmpty || isContains) {
        shownIndexes.add(i);
      }
      i++;
    });
  }

  @override
  void initState() {
    _updateShownIndexes('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      elevation: 20.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: new Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            titleBar(),
            searchBar(),
            list(),
            buttonWrapper(),
          ],
        ),
      ),
    );
  }

  Widget titleBar() {
    return widget.hint != null
        ? new Container(
            margin: EdgeInsets.only(bottom: 8),
            child: widget.hint,
          )
        : new Container();
  }

  Widget searchBar() {
    return new Container(
      child: new Stack(
        children: <Widget>[
          new TextField(
            inputFormatters: [
              new BlacklistingTextInputFormatter(new RegExp(
                  '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
            ],
            controller: txtSearch,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            autofocus: true,
            onChanged: (value) {
              _updateShownIndexes(value);
              setState(() {});
            },
          ),
          new Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: new Center(
              child: new Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          txtSearch.text.isNotEmpty
              ? new Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: new Center(
                    child: new InkWell(
                      onTap: () {
                        _updateShownIndexes('');
                        setState(() {
                          txtSearch.text = '';
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: new Container(
                        width: 32,
                        height: 32,
                        child: new Center(
                          child: new Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  Widget list() {
    return new Expanded(
      child: new ListView.builder(
        itemBuilder: (context, index) {
          DropdownMenuItem item = widget.items[shownIndexes[index]];
          return new InkWell(
            onTap: () {
              Navigator.pop(context, item.value);
            },
            child: item,
          );
        },
        itemCount: shownIndexes.length,
      ),
    );
  }

  Widget buttonWrapper() {
    return new Container(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('Close', style: defaultButtonStyle),
          )
        ],
      ),
    );
  }
}
