import 'package:cinema_frontend/UI/widgets/CustomDropdownButton.dart';
import 'package:cinema_frontend/UI/widgets/CustomHorizontalDivider.dart';
import 'package:cinema_frontend/UI/widgets/InlineDetailText.dart';
import 'package:cinema_frontend/UI/widgets/PurchaseDetail.dart';
import 'package:cinema_frontend/model/Model.dart';
import 'package:cinema_frontend/model/objects/LoginState.dart';
import 'package:cinema_frontend/model/objects/Purchase.dart';
import 'package:cinema_frontend/model/objects/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class UserPage extends StatefulWidget {

  final User user;
  final Future<List<Purchase>> lastMonthPurchaseList;

  const UserPage({Key key, this.user, this.lastMonthPurchaseList}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {

  Future<int> totalPages;
  int pageSize = 7;
  int pageNumber = 0;
  String sortBy = "purchaseTime";
  String order = "descending";
  Future<List<Purchase>> purchasePage;

  @override
  void initState() {
    super.initState();
    totalPages = Model.sharedInstance.getTotalPagesNumber(widget.user, pageSize.toString());
    purchasePage = Model.sharedInstance.getPurchaseHistoryByUser(widget.user, pageNumber.toString(), pageSize.toString(), sortBy, order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My profile",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                Model.sharedInstance.logOut();
                Provider.of<LoginState>(context, listen: false).setLoginState(false);
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: Text("You have correctly signed out"),
                  content: Text("Hope to see you soon!"),
                  actions: [
                    TextButton(
                      onPressed:() {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text("OK")
                    )
                  ],
                ));
              },
              child: Text("Sign out", style: Theme.of(context).textTheme.bodyText1),
              style: ElevatedButton.styleFrom(primary: Theme.of(context).accentColor),
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  Flexible(child: InlineDetailText(title: "First name: ", value: widget.user.firstName,)),
                  SizedBox(height: 10,),
                  Flexible(child: InlineDetailText(title: "Last name: ", value: widget.user.lastName,)),
                  SizedBox(height: 10,),
                  Flexible(child: InlineDetailText(title: "Phone number: ", value: widget.user.phoneNumber,)),
                  SizedBox(height: 10,),
                  Flexible(child: InlineDetailText(title: "Email: ", value: widget.user.email,)),
                  SizedBox(height: 10,),
                  Flexible(child: InlineDetailText(title: "Address: ", value: widget.user.address,)),
                ],
              )
            ),
          ),
          SizedBox(width: 30),
          Flexible(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                        "PURCHASE HISTORY",
                        style: Theme.of(context).textTheme.headline2
                    ),
                  ),
                  CustomHorizontalDivider(),
                  _pageSelectionButtons(),
                  CustomHorizontalDivider(),
                  Flexible(
                    child: FutureBuilder(
                      future: purchasePage,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            if(snapshot.data.length > 0){
                              return Container(
                                alignment: Alignment.topCenter,
                                child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    Purchase purchase = snapshot.data[index];
                                    return Container(
                                        padding: EdgeInsets.all(4),
                                        child: PurchaseDetail(
                                          time: purchase.purchaseTime,
                                          price: purchase.totalPrice.toString(),
                                          title: purchase.scheduledShow.event.title,
                                          subtitle: purchase.scheduledShow.startDateTime,
                                          orderedSeats: purchase.orderedSeatList,
                                        )
                                    );
                                  },
                                ),
                              );
                            }
                            else {
                              return Container(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  "There are no purchases in your purchase history",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              );
                            }
                          }
                          else if(snapshot.hasError) {
                            return Container(child: Text("${snapshot.error}"));
                          }
                          else {
                            return Container(
                                margin: EdgeInsets.all(8),
                                child: CircularProgressIndicator()
                            );
                          }
                        }
                    ),
                  ),
                ],
              )
            ),
          ),
          SizedBox(width: 30),
          Flexible(
            flex: 2,
            child: Container(
              margin: EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Column(
                children:[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "YOUR FAVOURITE FILM GENRES OVER THE LAST 30 DAYS",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                  CustomHorizontalDivider(),
                  SizedBox(height: 50,),
                  _genrePieChart()
                ]
              ),
            )
          )
        ],
      )
    );
  }

  _changePage(int index) {
    setState(() {
      pageNumber = index;
      purchasePage = Model.sharedInstance.getPurchaseHistoryByUser(widget.user, pageNumber.toString(), pageSize.toString(), sortBy, order);
    });
  }

  _pageSelectionButtons() {
    return Row(
      children: [
        SizedBox(width: 30),
        FutureBuilder(
            future: totalPages,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return Container(
                    width: 280,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: pageNumber==0 ? null : () => _changePage(0),
                          child: Icon(Icons.first_page),
                        ),
                        ElevatedButton(
                            onPressed: pageNumber==0 ? null : () => _changePage(pageNumber-1),
                            child: Icon(Icons.navigate_before)
                        ),
                        ElevatedButton(
                            onPressed: pageNumber==snapshot.data-1 ? null : () => _changePage(pageNumber+1),
                            child: Icon(Icons.navigate_next)
                        ),
                        ElevatedButton(
                            onPressed: pageNumber==snapshot.data-1 ? null : () => _changePage(snapshot.data-1),
                            child: Icon(Icons.last_page)
                        )
                      ]
                    )
                );
              }
              else {
                return Center(
                  child: CircularProgressIndicator(color: Theme.of(context).accentColor),
                );
              }
            }
        ),
        Text("Results per page:"),
        SizedBox(width: 10),
        Flexible(child: CustomDropdownButton(icon: Icon(Icons.format_list_numbered), defaultValue: pageSize.toString(), options: ["5","7","15"], refreshPageable: _updatePageFilters)),
        SizedBox(width: 10),
        Text("Order by:"),
        SizedBox(width: 10),
        Flexible(child: CustomDropdownButton(icon: Icon(Icons.sort_by_alpha), defaultValue: "Purchase time", options: ["Price", "Purchase time"], refreshPageable: _updatePageFilters)),
        SizedBox(width: 10),
        Flexible(child: CustomDropdownButton(icon: Icon(Icons.sort), defaultValue: "Descending", options: ["Ascending", "Descending"], refreshPageable: _updatePageFilters,)),
      ],
    );
  }

  _updatePageFilters(value) {
    setState(() {
      switch(value){
        case "5":
          pageSize = 5; break;
        case "9":
          pageSize = 9; break;
        case "15":
          pageSize = 15; break;
        case "Price":
          sortBy = "totalPrice"; break;
        case "Purchase time":
          sortBy = "purchaseTime"; break;
        case "Ascending":
          order = "ascending"; break;
        case "Descending":
          order = "descending";
      }
      pageNumber = 0;
      totalPages = Model.sharedInstance.getTotalPagesNumber(widget.user, pageSize.toString());
      purchasePage = Model.sharedInstance.getPurchaseHistoryByUser(widget.user, pageNumber.toString(), pageSize.toString(), sortBy, order);
    });

  }

  _genrePieChart(){
    return Flexible(
      child: FutureBuilder(
          future: widget.lastMonthPurchaseList,
          builder: (context, snapshot) {
            Map<String,double> dataMap = new Map(); //mappa per costruire il grafico
            if(snapshot.hasData) {
              if(snapshot.data.length > 0){
                for(Purchase p in snapshot.data){
                  String genre = p.scheduledShow.event.genreSet.first.toString();
                  dataMap.update(genre, (value) => value+1, ifAbsent: () => 1);
                }
                return Container(
                  width: 500,
                  height: 500,
                  child: PieChart(
                    dataMap: dataMap,
                    animationDuration: Duration(seconds:3),
                    chartType: ChartType.ring,
                    ringStrokeWidth: 64,
                    chartLegendSpacing: 48,
                    legendOptions: LegendOptions(
                      legendPosition: LegendPosition.bottom
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: true
                    ),
                  )
                );
              }
              else {
                return Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "There are no purchases in the last month",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              }
            }
            else if(snapshot.hasError) {
              return Container(child: Text("${snapshot.error}"));
            }
            else {
              return Container(
                  margin: EdgeInsets.all(8),
                  child: CircularProgressIndicator()
              );
            }
          }
      ),
    );
  }

}