//主页面
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myflutterdemo/view/HomePageRoute.dart';
import 'package:myflutterdemo/view/KonwledgePageRoute.dart';
import 'package:myflutterdemo/view/ProjectPageRoute.dart';
import 'package:myflutterdemo/view/PersonPageRoute.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavigationPageState();
  }
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  //TickerProviderStateMixin-->添加屏幕刷新回调
  List<Widget> pageData; //存储首页几个切片页面

  int currentPosition = 0; //当前页面下标

  BottomNavigationBarType animType = BottomNavigationBarType.fixed; //底部导航栏动画样式

  @override
  Widget build(BuildContext context) {
    //设置底部导航栏
    final BottomNavigationBar botNavBar = new BottomNavigationBar(
      items: [
        new BottomNavigationBarItem(
          icon: new Icon(
            Icons.home, //设置图片
            color: currentPosition == 0
                ? Colors.green
                : Colors.blue, //设置选择与未选择图片颜色
          ),
          title: new Text(
            "主页",
            style: new TextStyle(
                color: currentPosition == 0 ? Colors.green : Colors.blue,
                fontSize: 12.0,
                fontStyle: FontStyle.italic),
          ), //设置文字以及样式
        ),
        new BottomNavigationBarItem(
          icon: new Icon(
            Icons.widgets, //设置图片
            color: currentPosition == 1
                ? Colors.green
                : Colors.blue, //设置选择与未选择图片颜色
          ),
          title: new Text(
            "知识体系",
            style: new TextStyle(
                color: currentPosition == 1 ? Colors.green : Colors.blue,
                fontSize: 12.0,
                fontStyle: FontStyle.italic),
          ), //设置文字以及样式
        ),
        new BottomNavigationBarItem(
          icon: new Icon(
            Icons.work, //设置图片
            color: currentPosition == 2
                ? Colors.green
                : Colors.blue, //设置选择与未选择图片颜色
          ),
          title: new Text(
            "项目",
            style: new TextStyle(
                color: currentPosition == 2 ? Colors.green : Colors.blue,
                fontSize: 12.0,
                fontStyle: FontStyle.italic),
          ), //设置文字以及样式
        ),
        new BottomNavigationBarItem(
          icon: new Icon(
            Icons.person, //设置图片
            color: currentPosition == 3
                ? Colors.green
                : Colors.blue, //设置选择与未选择图片颜色
          ),
          title: new Text(
            "个人中心",
            style: new TextStyle(
                color: currentPosition == 3 ? Colors.green : Colors.blue,
                fontSize: 12.0,
                fontStyle: FontStyle.italic),
          ), //设置文字以及样式
        ),
      ],
      currentIndex: currentPosition, //当前选中下标
      type: animType, //跳转动画类型
      onTap: (position) {
        //点击下标展示对应的页面
        setState(() {
          currentPosition = position;
        });
      },
    );
    print("--------------->$pageData");
    return Scaffold(
      //保持切换每个tab的状态。作用是显示第index个child，其它child在页面上是不可见的，但所有child的状态都被保持
      body: IndexedStack(
        index: currentPosition,
        children:pageData,
      ),
      bottomNavigationBar: botNavBar,
    );
  }

  @override
  void initState() {
    print("--------------->$pageData.length");
    //创建之前填充数据
    pageData = new List();
    pageData
      ..add(HomePageRoute())
      ..add(KnowledgePageRoute())
      ..add(ProjectPageRoute())
      ..add(PersonPageRoute());
    print("--------------->$pageData.length");
    super.initState();
  }
}
