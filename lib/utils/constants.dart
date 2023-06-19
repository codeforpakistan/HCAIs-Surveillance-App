class Constants {
  static const dev = false;
  static const local = true;
  static const Local_URL = 'http://localhost:3000';
  static const Server_URL =
      dev ? 'http://18.141.220.82:8080' : 'http://18.141.220.82:3000'; //prod
  static const BASE_URL = local ? Local_URL : Server_URL;
  static const API_KEY =
      'hzTtuT3xSbrqzXVBukZ5n9PlLNL0gmMsZa7mzMCAnym6KniAKOzZbNZ4D9euat2uiTBBiBtebZ5u8DhBAh9zZ3nr_'; //prod
}
