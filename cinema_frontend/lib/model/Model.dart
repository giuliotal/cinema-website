import 'dart:async';
import 'dart:convert';
import 'package:cinema_frontend/model/objects/User.dart';
import 'package:cinema_frontend/model/support/CustomExceptions.dart';
import 'package:cinema_frontend/model/support/LoginResult.dart';
import 'package:intl/intl.dart';
import 'package:cinema_frontend/model/managers/RestManager.dart';
import 'package:cinema_frontend/model/objects/AuthenticationData.dart';
import 'package:cinema_frontend/model/objects/Event.dart';
import 'package:cinema_frontend/model/objects/ScheduledShow.dart';
import 'package:cinema_frontend/model/objects/Purchase.dart';
import 'package:cinema_frontend/model/support/Constants.dart';

import 'objects/Purchase.dart';

class Model {
  static Model sharedInstance = Model();

  RestManager _restManager = RestManager();
  AuthenticationData _authenticationData;


  Future<LoginResult> logIn(String email, String password) async {
    try {
      Map<String, String> params = Map();
      params["grant_type"] = "password";
      params["client_id"] = Constants.CLIENT_ID;
      params["client_secret"] = Constants.CLIENT_SECRET;
      params["username"] = email;
      params["password"] = password;
      String result = await _restManager.makePostRequest(
          Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGIN,
          params, type: HeaderType.URLENCODED);
      _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
      _restManager.token = _authenticationData.accessToken;
      Timer.periodic(
          Duration(seconds: (_authenticationData.expiresIn - 50)), (Timer t) {
        _refreshToken();
      });
      return LoginResult.LOGGED;
    }
    on UnauthorizedException catch (e) {
      String error = jsonDecode(e.body)['error_description'];
      if (error == "Invalid user credentials") {
        return LoginResult.ERROR_WRONG_CREDENTIALS;
      }
      else if (error == "Account is not fully set up") {
        return LoginResult.ERROR_NOT_FULLY_SETUP;
      }
      else {
        return LoginResult.ERROR_UNKNOWN;
      }
    }
    catch(err) {
      return LoginResult.ERROR_UNKNOWN;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      Map<String, String> params = Map();
      params["grant_type"] = "refresh_token";
      params["client_id"] = Constants.CLIENT_ID;
      params["client_secret"] = Constants.CLIENT_SECRET;
      params["refresh_token"] = _authenticationData.refreshToken;
      String result = await _restManager.makePostRequest(
          Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGIN,
          params, type: HeaderType.URLENCODED);
      _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
      if (_authenticationData.hasError()) {
        return false;
      }
      _restManager.token = _authenticationData.accessToken;
      return true;
    }
    catch (e) {
      return false;
    }
  }

  Future<bool> logOut() async {
    try {
      Map<String, String> params = Map();
      _restManager.token = null;
      params["client_id"] = Constants.CLIENT_ID;
      params["client_secret"] = Constants.CLIENT_SECRET;
      params["refresh_token"] = _authenticationData.refreshToken;
      await _restManager.makePostRequest(
          Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGOUT,
          params, type: HeaderType.URLENCODED);
      return true;
    }
    catch (e) {
      return false;
    }
  }

  Future<String> createUser(User user, String password, String role) async {
    try {
      Map<String, String> params = Map();
      params['password'] = password;
      params['role'] = role;
      return await _restManager.makePostRequest(
          Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_ADD_USER, user,
          params: params);
    }
    catch(e) {
      print(e);
      return Future.error(e); // errore gestito nella pagina di Login
    }
  }
  
  Future<User> getUserByEmail(String email) async {
    Map<String, String> params = Map();
    params["email"] = email;
    try {
      return User.fromJson(jsonDecode(await _restManager.makeGetRequest(
          Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_SEARCH_USER,
          params)));
    }
    catch (e) {
      rethrow;
    }
  }

  Future<List<Event>> getComingSoonEvents() async {
    try {
      return List<Event>.from(jsonDecode(await _restManager.makeGetRequest(
          Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_SEARCH_COMING_SOON))
          .map((i) => Event.fromJson(i))
          .toList());
    }
    catch(e){
      print(e);
      rethrow;
    }
  }

  Future<List<Event>> getEventsByDate(String date) async {
    try {
      Map<String, String> params = Map();
      params["date"] = date;
      return List<Event>.from(json.decode(await _restManager.makeGetRequest(
          Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_SEARCH_BY_DATE,
          params)).map((i) => Event.fromJson(i))).toSet().toList();
    }
    catch(e) {
      print(e);
      rethrow;
    }

  }

  Future<List<ScheduledShow>> getScheduledShowsByEventAndDate(int eventId, DateTime date) async {
    try {
      String formattedDate = DateFormat('dd-MM-yyyy').format(date.toLocal());
      return List<ScheduledShow>.from(json.decode(
          await _restManager.makeGetRequest(Constants.ADDRESS_STORE_SERVER,
              Constants.REQUEST_SHOWS_BY_EVENT_AND_DATE +
                  "/$eventId/$formattedDate")).map((i) =>
          ScheduledShow.fromJson(i)).toList());
    }
    catch(e) {
      print(e);
      rethrow;
    }
  }

  Future<ScheduledShow> getScheduledShowById(int id) async {
    try {
      return ScheduledShow.fromJson(json.decode(await _restManager.makeGetRequest(Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_SHOW_BY_ID+"/$id")));
    }
    catch(e) {
      rethrow;
    }
  }

  Future<String> addPurchase(Purchase purchase) async {
    try {
        return await _restManager.makePostRequest(Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_MAKE_PURCHASE, purchase);
    }
    catch (e) {
      return Future.error(e); // errore gestito nella pagina di SeatSelection
    }
  }

  Future<List<Purchase>> getPurchaseHistoryByUser(User user, String pageNumber, String pageSize, String sortBy, String order) async {
    try {
      Map<String, String> params = Map();
      params["pageNumber"] = pageNumber;
      params["pageSize"] = pageSize;
      params["sortBy"] = sortBy;
      params["order"] = order;

      return List<Purchase>.from(json.decode(await _restManager.makePostRequest(Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_PURCHASE_HISTORY, user, params: params)).map((i) => Purchase.fromJson(i))).toList();
    } catch(e) {
     rethrow;
    }
  }

  Future<List<Purchase>> getLastMonthPurchaseHistory(User user) async {
    DateTime current = DateTime.now();
    String currentMonth = current.month < 10 ? "0${current.month}" : current.month;
    DateTime past = current.subtract(new Duration(days:30));
    String pastMonth = past.month < 10 ? "0${past.month}" : past.month;
    Map<String, String> params = Map();
    params["start_date"] = "${past.day}-$pastMonth-${past.year}";
    params["end_date"] = "${current.day}-$currentMonth-${current.year}";

    return List<Purchase>.from(json.decode(await _restManager.makePostRequest(Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_PURCHASE_HISTORY_BY_DATE, user, params: params)).map((i) => Purchase.fromJson(i))).toList();
  }

  Future<int> getTotalPagesNumber(User user, String pageSize) async {
    try {
      Map<String, String> params = Map();
      params["pageSize"] = pageSize;
      return int.parse(await _restManager.makePostRequest(Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_PURCHASE_HISTORY_TOTAL_PAGES, user, params: params));
    }catch(e) {
      rethrow;
    }
  }

  // Future<List<Event>> searchEvent(String title) async {
  //   Map<String, String> params = Map();
  //   params["title"] = title;
  //   try {
  //     return List<Event>.from(jsonDecode(await _restManager.makeGetRequest(
  //         Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_SEARCH_BY_TITLE,
  //         params)).map((i) => Event.fromJson(i)).toList());
  //   }
  //   catch (e) {
  //     return null; // not the best solution
  //   }
  // }

  // Future<List<Event>> searchAllEvents() async {
  //   try {
  //     return List<Event>.from(json.decode(await _restManager.makeGetRequest(Constants.ADDRESS_STORE_SERVER, Constants.REQUEST_SEARCH_ALL)).map((i) => Event.fromJson(i)).toList());
  //   }
  //   catch (e) {
  //     return null; // not the best solution
  //   }
  // }

}