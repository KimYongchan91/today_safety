const Map<String, String> mapFormatSi = {
  '서울특별시': '서울',
  '경기도': '경기',
  '부산광역시': '부산',
  '울산광역시': '울산',
  '대구광역시': '대구',
  '대전광역시': '대전',
  '인천광역시': '인천',
  '광주광역시': '광주',
  '세종특별자치시': '세종',
  '강원특별자치도': '강원',
  '제주특별자치도': '제주',
  '경상북도': '경북',
  '경상남도': '경남',
  '충청북도': '충북',
  '충청남도': '충남',
  '전라북도': '전북',
  '전라남도': '전남',
};

String formatAddressSi(String si) {
  String result = si;
  for (var element in mapFormatSi.keys) {
    if(si.contains(element)){
      result = si.replaceAll(element, mapFormatSi[element]!);
      //바로 종료되도록
      break;
    }
  }

  return result;
}
