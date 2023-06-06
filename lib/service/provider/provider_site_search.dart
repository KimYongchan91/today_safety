import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';

import '../../const/model/model_site.dart';
import '../../my_app.dart';

const String _tagDebouncer = 'debounce_input_delay_for_search';

class ProviderSiteSearch extends ChangeNotifier {
  List<ModelSite> listModelSite = [];
  bool isSearching = false;
  String keywordLastSearch = '';

  void changeIsSearching(bool isSearching){
    this.isSearching = isSearching;
    notifyListeners();
  }

  void handleInput(String? keyword) {
    if (keyword == null) {
      EasyDebounce.cancel(_tagDebouncer);
      changeIsSearching(false);
      return;
    }

    EasyDebounce.debounce(_tagDebouncer, const Duration(milliseconds: 1000), () {
      searchByKeyWord(keyword);
    });
  }

  Future<void> searchByKeyWord(String keyword) async {
    if(keyword == keywordLastSearch){
      MyApp.logger.d('마지막 키워드와 같으므로 새로 검색하지 않음.');
      return;
    }

    changeIsSearching(true);
    MyApp.logger.d('검색을 시작하자! $keyword');
    await Future.delayed(const Duration(milliseconds: 1000));
    changeIsSearching(false);
  }
}
