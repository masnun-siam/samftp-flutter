enum SamFtpUrls {
  movie._('http://172.16.50.7', 'http://172.16.50.7/SAM-FTP-2/English%20Movies/'),
  foreign._('http://172.16.50.7', "http://172.16.50.7/SAM-FTP-2/Foreign%20Language%20Movies/"),
  hindi._('http://172.16.50.9', "http://172.16.50.9/SAM-FTP-1/Hindi%20Movies/"),
  south._('http://172.16.50.14', "http://172.16.50.14/SAM-FTP-14/SOUTH%20INDIAN%20MOVIES/South%20Movies/"),
  hindiDubbed._('http://172.16.50.14', "http://172.16.50.14/SAM-FTP-14/SOUTH%20INDIAN%20MOVIES/Hindi%20Dubbed/"),
  animation._('http://172.16.50.10', "http://172.16.50.10/SAM-FTP-3/Animation%20Movies/"),
  bangla._('http://172.16.50.10', "http://172.16.50.10/SAM-FTP-3/Kolkata%20Bangla%20Movies/"),
  tv._('http://172.16.50.12', 'http://172.16.50.12/SAM-FTP-1/TV-WEB-Series/'),
  anime._('http://172.16.50.10',
      'http://172.16.50.10/SAM-FTP-3/Anime%20%26%20Cartoon%20TV%20Series/'),
  kdrama._('http://172.16.50.9',
      'http://172.16.50.9/SAM-FTP-1/KOREAN%20TV%20%26%20WEB%20Series/');

  final String base, start;
  const SamFtpUrls._(this.base, this.start);
}

String getUri(SamFtpUrls base, [String? path]) => base.base + (path ?? '');
