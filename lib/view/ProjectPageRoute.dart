import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myflutterdemo/http/Http.dart';
import 'package:myflutterdemo/http/api/Api.dart';
import 'package:myflutterdemo/item/ProjectContentItem.dart' as contentItem;
import 'package:myflutterdemo/item/ProjectListItem.dart' as listData;
import 'package:myflutterdemo/util/CommonUtil.dart';
import 'package:myflutterdemo/view/publicview/PublicView.dart';

//项目
class ProjectPageRoute extends StatefulWidget {
  ProjectPageRoute({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProjectPageRouteState();
  }
}

class _ProjectPageRouteState extends State<ProjectPageRoute> {
  List<listData.Data> _dataList = [];

  @override
  Widget build(BuildContext context) {
    return _dataList.length == 0
        ? SpinKitCircle(
            //等待加载框
            itemBuilder: (_, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.grey,
                ),
              );
            },
          )
        : new DefaultTabController(
            //tabBar必须要有个TabController
            length: _dataList.length,
            child: new Scaffold(
              appBar: AppBar(
                  title: Text("项目"),
                  centerTitle: true,
                  bottom: TabBar(
                      isScrollable: true, //可以滑动
                      tabs: _dataList.map((item) {
                        return Tab(
                          text: item.name,
                        );
                      }).toList())),
              body: new TabBarView(
                  children: _dataList.map((item) {
                return ProjectListWithId(item.id);
              }).toList()),
            ));
  }

  //获取tab数据
  void _getTabList() async {
    var url = Api.PROJECT_TREE;
    var response = await HttpUtil().get(url);
    var item = listData.ProjectListItem.fromJson(response);
    setState(() {
      _dataList = item.data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getTabList();
  }
}

//构建body
class ProjectListWithId extends StatefulWidget {
  final int id;

  ProjectListWithId(this.id, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProjectListWithIdState(id);
  }
}

class _ProjectListWithIdState extends State<ProjectListWithId>
    with AutomaticKeepAliveClientMixin {
  int id;
  var pageSize =20;
  var page = 0;
  List<contentItem.Datas> data = [];

  //是否有更多数据
  bool isHasNoMore = false;

  _ProjectListWithIdState(this.id);

  final ScrollController _scrollController =
      new ScrollController(keepScrollOffset: false);

//这个key用来在不是手动下拉，而是点击某个button或其它操作时，代码直接触发下拉刷新
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return data.length == 0
        ? SpinKitCircle(
            itemBuilder: (context, index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.blue),
              );
            },
          )
        : ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: data.length+1,
            controller: _scrollController,
            itemBuilder: (context, index) {
              return _getItem(index);
            },
          );
  }

  //获取数据
  void _getData(bool isLoadMore) async {
    var url = Api.PROJECT_LIST + "$page/json";
    var response = await HttpUtil.getInstance().get(url, data: {"cid": id});
    var item = contentItem.ProjectContentItem.fromJson(response);
    if (item.data.datas.length < pageSize) {
      isHasNoMore = true;
    } else {
      isHasNoMore = false;
    }
    print("------------>$isHasNoMore");
    if (isLoadMore) {
      data.addAll(item.data.datas);
      setState(() {});
    } else {
      setState(() {
        data = item.data.datas;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData(false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        _getData(true);
      }
    });
  }

  Widget _getItem(int index) {
    if (index == data.length) {
      if (isHasNoMore) {
        return BuildNoMoreData();
      } else {
        return BuildLoadMoreLoading();
      }
    } else {
      var item = data[index];
      return _buildCardItem(item, index);
    }
  }

  Widget _buildCardItem(contentItem.Datas item, int index) {
    var _imageWidth = 80.0;
    var _height = 120.0;
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(item.publishTime, isUtc: true);
    return GestureDetector(
      onTap: () {},
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: "images/code.jpg",//占位图
                image: item.envelopePic,
                fit: BoxFit.cover,
                width: _imageWidth,
                height: _height,
              ),
              Container(
                height: 120,
                margin: EdgeInsets.only(left: 8),
                width: CommonUtil.getScreenWidth(context) - _height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.desc,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Text(
                              item.author,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blueAccent),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                            decoration: BoxDecoration(color: Colors.red),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: Text(
                            "${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute}",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                          ),
                          flex: 1,
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
