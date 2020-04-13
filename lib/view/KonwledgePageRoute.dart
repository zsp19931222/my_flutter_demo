import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myflutterdemo/http/Http.dart';
import 'package:myflutterdemo/http/api/Api.dart';
import 'package:myflutterdemo/item/KnowledgeItem.dart';

//知识体系
class KnowledgePageRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KnowledgeRouteState();
  }
}

class _KnowledgeRouteState extends State<KnowledgePageRoute> {
  List<Data> _list = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("知识体系"),
        centerTitle: true, //居中显示
      ),
      body: _listView(),
    );
  }

  //构建listview
  ListView _listView() {
    return ListView.builder(
      itemCount: _list.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return item(_list[index]);
      },
    );
  }

  //构建item
  Widget item(Data item) {
        return new GestureDetector(
            onTap: () {
            },
            child: new Card(
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          child: Text(item.name,
                            style: new TextStyle(
                                fontSize: 18.0,
                                color: Colors.black
                            ),
                          ),
                          margin: EdgeInsets.only(
                              left: 10.0, bottom: 10.0, top: 15.0),
                        ),
                        //流式布局
                        Wrap(
                          children: item.children.map((item) {
                            return new Container(
                              margin: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 3.0,
                                  top: 3.0),
                              child: Text(item.name, style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.0
                              ),),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  new Icon(Icons.navigate_next),
                ],
              ),
            )
        );
  }

//获取数据
  void getListData() async {
    print("进来了");
    var url = Api.KNOWLEDGE_TREE;
    var response = await HttpUtil().get(url);
    var item = new KnowledgeItem.fromJson(response);
    print(item);
    setState(() {
      _list = item.data;
    });
  }

  @override
  void initState() {
    super.initState();
    getListData();
  }
}
