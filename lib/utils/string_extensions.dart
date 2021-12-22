import 'my_utils.dart';

extension StringUtils on String {
  bool get isNum => MyUtils.isNum(this);

  bool get isNumericOnly => MyUtils.isNumericOnly(this);

  bool get isAlphabetOnly => MyUtils.isAlphabetOnly(this);

  bool get isBool => MyUtils.isBool(this);

  bool get isVectorFileName => MyUtils.isVector(this);

  bool get isImageFileName => MyUtils.isImage(this);

  bool get isAudioFileName => MyUtils.isAudio(this);

  bool get isVideoFileName => MyUtils.isVideo(this);

  bool get isTxtFileName => MyUtils.isTxt(this);

  bool get isDocumentFileName => MyUtils.isWord(this);

  bool get isExcelFileName => MyUtils.isExcel(this);

  bool get isPPTFileName => MyUtils.isPPT(this);

  bool get isAPKFileName => MyUtils.isAPK(this);

  bool get isPDFFileName => MyUtils.isPDF(this);

  bool get isHTMLFileName => MyUtils.isHTML(this);

  bool get isURL => MyUtils.isURL(this);

  bool get isEmail => MyUtils.isEmail(this);

  bool get isPhoneNumber => MyUtils.isPhoneNumber(this);

  bool get isDateTime => MyUtils.isDateTime(this);

  bool get isMD5 => MyUtils.isMD5(this);

  bool get isSHA1 => MyUtils.isSHA1(this);

  bool get isSHA256 => MyUtils.isSHA256(this);

  bool get isBinary => MyUtils.isBinary(this);

  bool get isIPv4 => MyUtils.isIPv4(this);

  bool get isIPv6 => MyUtils.isIPv6(this);

  bool get isHexadecimal => MyUtils.isHexadecimal(this);

  bool get isPalindrom => MyUtils.isPalindrom(this);

  bool get isPassport => MyUtils.isPassport(this);

  bool get isCurrency => MyUtils.isCurrency(this);

  bool get isCpf => MyUtils.isCpf(this);

  bool get isCnpj => MyUtils.isCnpj(this);

  bool isCaseInsensitiveContains(String b) =>
      MyUtils.isCaseInsensitiveContains(this, b);

  bool isCaseInsensitiveContainsAny(String b) =>
      MyUtils.isCaseInsensitiveContainsAny(this, b);

  String? get capitalize => MyUtils.capitalize(this);

  String? get capitalizeFirst => MyUtils.capitalizeFirst(this);

  String get removeAllWhitespace => MyUtils.removeAllWhitespace(this);

  String? get camelCase => MyUtils.camelCase(this);

  String? get paramCase => MyUtils.paramCase(this);

  String numericOnly({bool firstWordOnly = false}) =>
      MyUtils.numericOnly(this, firstWordOnly: firstWordOnly);

  String createPath([Iterable? segments]) {
    final path = startsWith('/') ? this : '/$this';
    return MyUtils.createPath(path, segments);
  }

  String removeZeroOnLastIndex(){
    String temp = this;
    while(temp.endsWith('0')){
      temp =  temp.remoteEndIndex();
    }
    if(temp.endsWith('.')){
      temp = temp.remoteEndIndex();
    }
    return temp;
  }
  
  String remoteEndIndex(){
    return substring(0, length-1);
  }
}