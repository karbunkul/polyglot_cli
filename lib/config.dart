class Config {
  final double version;
  final String parts;
  final String output;
  final String defaultLocale;

  Config({
    this.version = 1.0,
    this.parts = 'parts',
    this.output = '',
    this.defaultLocale = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'parts': parts,
      'output': output,
      'default-locale': defaultLocale,
    };
  }

  static fromJson(Map<String, dynamic> json) {
    return Config(
      version: json['version'],
      parts: json['parts'],
      output: json['output'],
      defaultLocale: json['default-locale'],
    );
  }
}
