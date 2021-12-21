class Constants {
  // app info
  static const String APP_VERSION = "0.0.1";
  static const String APP_NAME = "CINEMA CITRIGNO";

  // addresses
  static const String ADDRESS_STORE_SERVER = "localhost:8080";
  static const String ADDRESS_AUTHENTICATION_SERVER = "localhost:8180";

  // authentication
  static const String REALM = "Cinema";
  static const String CLIENT_ID = "cinema-login";
  static const String CLIENT_SECRET = "63bcd89e-60fd-4444-87ce-b5e3134f6b63";
  static const String REQUEST_LOGIN = "/auth/realms/" + REALM + "/protocol/openid-connect/token";
  static const String REQUEST_LOGOUT = "/auth/realms/" + REALM + "/protocol/openid-connect/logout";

  // requests
  static const String REQUEST_SEARCH_BY_TITLE = "/events/search/by_title";
  static const String REQUEST_SEARCH_ALL = "/events/all";
  static const String REQUEST_SEARCH_COMING_SOON = "/events/coming_soon";
  static const String REQUEST_SEARCH_BY_DATE = "/events/search/by_date";
  static const String REQUEST_SHOWS_BY_EVENT_AND_DATE = "/schedule/search_all";
  static const String REQUEST_SHOW_BY_ID = "/schedule/search_by_id";
  static const String REQUEST_ADD_USER = "/users/create";
  static const String REQUEST_SEARCH_USER = "users/search_by_email";
  static const String REQUEST_MAKE_PURCHASE = "/purchase";
  static const String REQUEST_PURCHASE_HISTORY = "/purchase/history";
  static const String REQUEST_PURCHASE_HISTORY_TOTAL_PAGES = "/purchase/history_pages";
  static const String REQUEST_PURCHASE_HISTORY_BY_DATE = "/purchase/search_by_date";

  // messages
  static const String MESSAGE_CONNECTION_ERROR = "connection_error";

}