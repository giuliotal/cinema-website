import 'dart:convert';
import 'dart:io';
import 'package:cinema_frontend/model/support/Constants.dart';
import 'package:cinema_frontend/model/support/CustomExceptions.dart';
import 'package:http/http.dart';

import 'package:cinema_frontend/model/support/ErrorListener.dart';

enum HeaderType {
  JSON, URLENCODED
}

enum HTTPMethod {
  GET, PUT, POST, DEL
}

class RestManager {

  ErrorListener delegate; //gestisce gli errori di rete (quelli HTTP vengono gestiti a parte)
  String token;

  Future<String> _makeRequest(String serverAddress, String servicePath, HTTPMethod method, HeaderType type, {Map<String, String> value, dynamic body}) async {
    Uri uri = Uri.http(serverAddress, servicePath, value);

    bool errorOccurred = false;
    int errCount = 0;
    while (true) {
      try {
        var response;

        // setting content type
        String contentType;
        dynamic formattedBody;

        if ( type == HeaderType.JSON ) {
          contentType = "application/json;charset=utf-8";
          formattedBody = json.encode(body);
        }
        else if ( type == HeaderType.URLENCODED ) {
          contentType = "application/x-www-form-urlencoded";
          formattedBody = body.keys.map((key) => "$key=${body[key]}").join("&");
        }

        // setting headers
        Map<String, String> headers = Map();
        headers[HttpHeaders.contentTypeHeader] = contentType;
        if ( token != null ) {
          headers[HttpHeaders.authorizationHeader] = 'bearer $token';
        }

        // making request
        switch (method) {
          case HTTPMethod.POST:
            response = await post(uri, headers: headers, body: formattedBody);
            break;
          case HTTPMethod.GET:
            response = await get(uri, headers: headers);
            break;
          case HTTPMethod.PUT:
            response = await put(uri, headers: headers);
            break;
          case HTTPMethod.DEL:
            response = await delete(uri, headers: headers);
            break;
        }

        if ( delegate != null && errorOccurred ) {
          delegate.errorNetworkGone();
          errorOccurred = false;
        }

        switch (response.statusCode) {
          case 200:
            return response.body;
          case 400:
            throw BadRequestException(response.body);
          case 401:
          case 403:
            throw UnauthorizedException(response.body);
          case 500:
          default:
            throw ServerException("Error occurred while communicating with server. Status code: ${response.statusCode}");
        }
      }
      on ServerException catch(e) {
        errCount++;
        print(e);
        if (delegate != null && !errorOccurred) {
          delegate.errorNetworkOccurred(Constants.MESSAGE_CONNECTION_ERROR);
          errorOccurred = true;
        }
        if(errCount > 3) rethrow; // ritenta un numero massimo di 3 volte

        // un nuovo tentativo viene effettuato con backoff lineare
        await Future.delayed(
            Duration(seconds: 5*errCount), () => null); // not the best solution
      }
    }
  }

  Future<String> makePostRequest(String serverAddress, String servicePath, dynamic body, {Map<String, String> params, HeaderType type = HeaderType.JSON}) async {
    return _makeRequest(serverAddress, servicePath, HTTPMethod.POST, type, value: params, body: body);
  }

  Future<String> makeGetRequest(String serverAddress, String servicePath, [Map<String, String> value, HeaderType type = HeaderType.JSON]) async {
    return _makeRequest(serverAddress, servicePath, HTTPMethod.GET, type, value: value);
  }

  Future<String> makePutRequest(String serverAddress, String servicePath, [Map<String, String> value, HeaderType type = HeaderType.JSON]) async {
    return _makeRequest(serverAddress, servicePath, HTTPMethod.PUT, type, value: value);
  }

  Future<String> makeDeleteRequest(String serverAddress, String servicePath, [Map<String, String> value, HeaderType type = HeaderType.JSON]) async {
    return _makeRequest(serverAddress, servicePath, HTTPMethod.DEL, type, value: value);
  }

}