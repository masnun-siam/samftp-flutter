enum SamFtpUrls {
  movie._('http://172.16.50.7', 'http://172.16.50.7/DHAKA-FLIX-7/English%20Movies/'),
  foreign._('http://172.16.50.7', 'http://172.16.50.7/DHAKA-FLIX-7/Foreign%20Language%20Movies/'),
  hindi._('http://172.16.50.14', "http://172.16.50.14/DHAKA-FLIX-14/Hindi%20Movies/"),
  south._('http://172.16.50.14', "http://172.16.50.14/DHAKA-FLIX-14/SOUTH%20INDIAN%20MOVIES/South%20Movies/"),
  hindiDubbed._('http://172.16.50.14', "http://172.16.50.14/DHAKA-FLIX-14/SOUTH%20INDIAN%20MOVIES/Hindi%20Dubbed/"),
  animation._('http://172.16.50.14', "http://172.16.50.14/DHAKA-FLIX-14/Animation%20Movies/"),
  bangla._('http://172.16.50.7', "http://172.16.50.7/DHAKA-FLIX-7/Kolkata%20Bangla%20Movies/"),
  tv._('http://172.16.50.12', 'http://172.16.50.12/DHAKA-FLIX-12/TV-WEB-Series/'),
  anime._('http://172.16.50.9',
      'http://172.16.50.9/DHAKA-FLIX-9/Anime%20%26%20Cartoon%20TV%20Series/'),
  kdrama._('http://172.16.50.14',
      'http://172.16.50.14/DHAKA-FLIX-14/KOREAN%20TV%20%26%20WEB%20Series/');

  final String base, start;
  const SamFtpUrls._(this.base, this.start);
}

String getUri(SamFtpUrls base, [String? path]) => base.base + (path ?? '');
