import 'dart:async';

import 'package:banner_view/banner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myflutterdemo/http/Http.dart';
import 'package:myflutterdemo/http/api/Api.dart';
import 'package:myflutterdemo/item/HomeItem.dart' as homeItem;
import 'package:myflutterdemo/item/BannerItem.dart' as bannerItem;
import 'package:myflutterdemo/util/CommonUtil.dart';
import 'package:myflutterdemo/util/ToastUtil.dart';

//首页
class HomePageRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends State<HomePageRoute>
    with AutomaticKeepAliveClientMixin {
  List<homeItem.Datas> homeData = []; //列表数据集合

  final int headerCount = 1;
  var bannerIndex = 0;
  final int pageSize = 20;
  var page = 0;

  //是否在加载
  bool isLoading = false;

  //是否有更多数据
  bool isHasNoMore = false;

  final ScrollController _scrollController =
  new ScrollController(keepScrollOffset: false);

  @protected
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        //刷新控件
        color: Colors.blue,
        child: buildCustomScrollView(),
        onRefresh:_refresh,
      ),
      appBar: AppBar(
        //AppBar
        title: Text("首页"),
        centerTitle: true, //居中显示
        actions: <Widget>[
          //带有图片操作AppBar
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              ShowToast("跳转搜索");
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getBannerList();
    getNewsListData(false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading) {
          page++;
          getNewsListData(true);
        }
      }
    });
    super.initState();
  }

  //刷新
  Future<Null> _refresh() {
    final Completer<Null> completer=Completer<Null>();
    homeData.clear();
    page=0;
    getNewsListData(false,completer);
    getBannerList();
    return completer.future;
  }

  //构建listview
  ListView buildCustomScrollView() {
    return ListView.builder(
      //ClampingScrollPhysics：Android下微光效果。
      //BouncingScrollPhysics：iOS下弹性效果。
      //保持ListView任何情况都能滚动，解决在RefreshIndicator的兼容问题。
      physics: AlwaysScrollableScrollPhysics(),
      //item的个数
      itemCount: homeData.length + headerCount + 1,
      //滚动位置和监听滚动事件
      controller: _scrollController,
      //它是列表项的构建器，类型为IndexedWidgetBuilder，返回值为一个widget。当列表滚动到具体的index位置时，会调用该构建器构建列表项
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildBanner();
        } else {
          return getItem(index - headerCount);
        }
      },
    );
  }

  //从网络获取新闻数据（异步）
  //我创建的，完成了调我的回调就行了: 用 Future。
  //我创建的，得我来结束它： 用Completer。
  void getNewsListData(bool isLoadMore, [Completer completer]) async {
    if (isLoadMore) {
      setState(() {
        isLoading = true;
      });
    }
    //异步获取响应数据
    var response = await HttpUtil().get(
        Api.HOME_LIST + page.toString() + "/json");
    var item = homeItem.HomeItem.fromJson(response); //转化为bean
    completer?.complete();
    //
    if (item.data.datas.length < pageSize) {
      isHasNoMore = true; //加载完成
    } else {
      isHasNoMore = false; //
    }
    if (isLoadMore) {
      isLoading = false;
      homeData.addAll(item.data.datas);
      setState(() {});
    } else {
      setState(() {
        homeData = item.data.datas;
      });
    }
  }

  //构建item
  Widget getItem(int i) {
    if (i == homeData.length) {
      if (isHasNoMore) {
        return _buildNoMoreData();
      } else {
        return _buildLoadMoreLoading();
      }
    } else {
      var itemData = homeData[i]; //获取当前item数据
      //设置时间
      var date = DateTime.fromMicrosecondsSinceEpoch(itemData.publishTime,
          isUtc: true);
      return buildCardItem(itemData, date, i);
    }
  }

  //构建没有更多数据提示
  Widget _buildNoMoreData() {
    return Container(
      margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
      alignment: Alignment.center,
      child: Text("没有更多数据了"),
    );
  }

  //构建加载更多控件
  Widget _buildLoadMoreLoading() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitFadingCircle(
                color: Colors.grey,
                size: 30.0,
              ),
              new Padding(padding: EdgeInsets.only(left: 10)),
              new Text("正在加载更多...")
            ],
          ),
        ),
      ),
    );
  }

  //构建item布局
  Card buildCardItem(homeItem.Datas item, DateTime date, int index) {
    return new Card(
        child: new InkWell(
          onTap: () {
            var url = homeData[index].link;
            var title = homeData[index].title;
            ShowToast("跳转详情页面");
          },
          child: new Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10.0),
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Container(
                      decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(3.0),
                          border: new Border.all(color: Colors.blue)),
                      child: new Text(
                        item.superChapterName,
                        style: new TextStyle(color: Colors.blue),
                      ),
                    ),
                    new Container(
                      margin: EdgeInsets.only(left: 5.0),
                      child: new Text(item.author),
                    ),
                    new Expanded(child: new Container()),
                    new Text(
                      "${date.year}年${date.month}月${date.day}日 ${date
                          .hour}:${date.minute}",
                      style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Container(
                      height: 80.0,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            width: CommonUtil.getScreenWidth(context) - 100,
                            child: new Text(
                              item.title,
                              softWrap: true, //换行
                              maxLines: 2,
                              style: new TextStyle(fontSize: 16.0),
                            ),
                            margin: EdgeInsets.only(top: 10.0),
                          ),
                          new Container(
                            child: new Text(
                              item.superChapterName + "/" + item.author,
                              style: new TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    item.envelopePic.isEmpty
                        ? new Container(
                      width: 60.0,
                      height: 60.0,
                    )
                        : new Image.network(
                      item.envelopePic,
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  //banner数据
  List<bannerItem.Data> bannerList = [];


  //构建banner
  Widget buildBanner() {
    return new Container(
      child: bannerList.length > 0 ? new BannerView(
        bannerList.map((bannerItem.Data item) {
          return new GestureDetector(
              onTap: () {
                ShowToast("跳转");
              },
              child: new Image.network(
                item.imagePath, fit: BoxFit.cover,)
          );
        }).toList(),
        cycleRolling: false,
        autoRolling: true,
        indicatorMargin: 8.0,
        indicatorNormal: this._indicatorItem(
            Colors.white),
        indicatorSelected: this._indicatorItem(
            Colors.white, selected: true),
        indicatorBuilder: (context, indicator) {
          return this._indicatorContainer(indicator);
        },
        onPageChanged: (index) {
          bannerIndex = index;
        },
      ) : new Container(),
      width: double.infinity,
      height: 200.0,
    );
  }

  //获取轮播图接口
  void getBannerList() async {
    var response = await HttpUtil().get(Api.BANNER_LIST);
    var item = new bannerItem.BannerItem.fromJson(response);
    bannerList.clear();
    bannerList = item.data;
    setState(() {});
  }

  //构建banner下面圆形指示图
  Widget _indicatorItem(Color color, {bool selected = false}) {
    double size = selected ? 10.0 : 6.0;
    return new Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.all(
          new Radius.circular(5.0),
        ),
      ),
    );
  }

  Widget _indicatorContainer(Widget indicator) {
    var container = new Container(
      height: 40.0,
      child: new Stack(
        children: <Widget>[
          new Opacity(
            opacity: 0.5,
            child: new Container(
              color: Colors.grey[300],
            ),
          ),
          new Container(
            margin: EdgeInsets.only(right: 10.0),
            child: new Align(
              alignment: Alignment.centerRight,
              child: indicator,
            ),
          ),
          new Align(
              alignment: Alignment.centerLeft,
              child: new Container(
                margin: EdgeInsets.only(left: 15),
                child: new Text(bannerList[bannerIndex].title),
              )
          ),
        ],
      ),
    );
    return new Align(
      alignment: Alignment.bottomCenter,
      child: container,
    );
  }


  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
