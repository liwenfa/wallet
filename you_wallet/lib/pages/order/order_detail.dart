
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:youwallet/service/trade.dart';
import 'package:youwallet/global.dart';
import 'package:common_utils/common_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youwallet/widgets/loadingDialog.dart';

class OrderDetail extends StatefulWidget {

  final arguments;

  OrderDetail({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page(arguments: this.arguments);
  }
}

// 收款tab页
class Page extends State<OrderDetail> {

  Page({this.arguments});

  Map arguments;
  final globalKey = GlobalKey<ScaffoldState>();
  Map detail;

  @override // override是重写父类中的函数
  void initState()  {
    print(this.arguments);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }


  Widget layout(BuildContext context) {
    return new Scaffold(
      key: globalKey,
      appBar: buildAppBar(context),
      body: FutureBuilder(
        future: this.getDetail(),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          /*表示数据成功返回*/
          if (snapshot.hasData) {
            Map response = snapshot.data;
            return buildPage(response);
          } else {
            return LoadingDialog();
          }
        },
      )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text(''),
      elevation: 0.0,
//      actions: this.appBarActions(),
    );
  }

  Widget LoadingWidget() {
    return Text('加载中。。。。。。。。。。');
  }

  Widget buildPage(Map item) {
    return new Container(
      alignment: Alignment.topCenter,
      child: new Container(
        padding: const EdgeInsets.all(40.0 ),
        child: new ListView(
          children: <Widget>[
            buildIcon(this.arguments['status']),
            new Text(
                this.arguments['status'],
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 30.0,
                    color: Colors.black,
                    height: 3.0,

                )
            ),
            new Column(
              children: <Widget>[
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('交易时间'),
                      buildValue(DateUtil.formatDateMs( int.parse( this.arguments['createTime']), format: DataFormats.full))
                    ]),
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('gas'),
                      buildValue(item['gas'])
                ]),
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('gasPrice'),
                      buildValue(item['gasPrice'])
                ]),
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('钱包地址'),
                      buildValue(item['from'])
                ]),
                SizedBox(
                  height: 20.0,
                ),
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('合约地址'),
                      buildValue(item['to'])
                ]),
                SizedBox(
                  height: 20.0,
                ),
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('交易号'),
                      buildValue(item['hash']),
                ]),
                SizedBox(
                  height: 20.0,
                ),
                new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildName('区块'),
                      buildValue(item['blockNumber'])
                ]),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            new Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 20.0), // 四周填充边距32像素
//                  color: Color(0xFFFFFFFF),
                child: new Column(
                  children: <Widget>[
                    QrImage(
                      backgroundColor:Colors.white,
                      data: item['hash'],
                      size: 100.0,
                    ),
                  ],
                )
            ),
            GestureDetector(
              child: Text(
                '到Etherscan查询更详细信息>',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 14.0
                ),
              ),
              onTap: () async {
                String url= Global.getDomain() + item['hash'];
                print(url);
                await launch(url);
              }
            )
          ],
        ),
      ),

    );
  }

  Widget buildName(String val) {
    return new Container(
//      color: Colors.lightBlue,
      width: 100.0,
      padding: const EdgeInsets.only(right: 10.0),
      margin: const EdgeInsets.only(bottom: 20.0),
      alignment: Alignment.centerRight,
      child: Text(
          val + ':',
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.0
          ),
      ),
    );
  }

  Widget buildValue(String val) {
    return Expanded(
      child: GestureDetector(
        onTap: (){
          _copyAddress(val);
          showSnackbar('复制成功');
        },
        child: Text(
          val,
          style: TextStyle(
              fontSize: 18.0
          ),
        ),
      )
    );
  }

  void  _copyAddress(val) {
    ClipboardData data = new ClipboardData(text:val);
    Clipboard.setData(data);
    this.showSnackbar('复制成功');
  }

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  Widget buildIcon(String status) {
    if (status == '进行中') {
      return Icon(Icons.autorenew, size: 80.0, color: Colors.green);
    } else if(status == '交易撤销') {
      return Icon(Icons.block, size: 80.0, color: Colors.red);
    } else {
      return Icon(IconData(0xe617, fontFamily: 'iconfont'),size: 80.0, color: Colors.green);
    }
  }

  Future<Map> getDetail() async {
    print('getDetail =>');
    print(this.arguments);
    Map response = await Trade.getTransactionByHash( this.arguments['txnHash']);
    print(response);
    return response;
  }

}
