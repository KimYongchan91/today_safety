import 'package:algolia/algolia.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';

import '../../const/model/model_site.dart';
import '../../my_app.dart';

const String _tagDebouncer = 'debounce_input_delay_for_search';
const int _lengthKeywordMin = 2;

typedef SearchByKeyword = Future<void> Function(String);

class ProviderSiteSearch extends ChangeNotifier {
  List<ModelSite> listModelSite = [];
  bool isSearching = false;
  String keywordLastSearch = '';

  void changeIsSearching(bool isSearching) {
    this.isSearching = isSearching;
    notifyListeners();
  }

  void clearInput() {
    EasyDebounce.cancel(_tagDebouncer);
    changeIsSearching(false);
    listModelSite.clear();
    notifyListeners();
    keywordLastSearch = "";
  }

  void handleInput(String? keyword) {
    if (keyword == null) {
      clearInput();

      return;
    }

/*    if (keyword == keywordLastSearch) {
      MyApp.logger.d('마지막 키워드와 같으므로 새로 검색하지 않음.');
      EasyDebounce.cancel(_tagDebouncer);
      changeIsSearching(false);
      return;
    }*/
    if (keyword.length < _lengthKeywordMin) {
      MyApp.logger.d('키워드가 $_lengthKeywordMin글자보다 작기에 검색하지 않음');
      clearInput();
      return;
    }

    EasyDebounce.debounce(_tagDebouncer, const Duration(milliseconds: 500), () {
      searchByKeyWord(keyword);
    });
  }

  Future<void> searchByKeyWord(String keyword) async {
    changeIsSearching(true);
    MyApp.logger.d('검색을 시작하자! $keyword');

    SearchByKeyword searchByKeyword;
    if (keywordLastSearch.isNotEmpty && keyword.startsWith(keywordLastSearch)) {
      searchByKeyword = _searchByKeywordFromCache;
    } else {
      searchByKeyword = _searchByKeywordFromServer;
    }

    await searchByKeyword(keyword);

    changeIsSearching(false);
    keywordLastSearch = keyword;

    notifyListeners();
  }

  Future<void> _searchByKeywordFromServer(String keyword) async {
    MyApp.logger.d("서버에서 검색");

    AlgoliaQuery algoliaQuery = MyApp.algolia.instance.index('fts_site').query(keyword);
    AlgoliaQuerySnapshot snap = await algoliaQuery.getObjects();
    MyApp.logger.d(snap.toMap());

    listModelSite.clear();
    for (var element in snap.hits) {
      ModelSite modelSite = ModelSite.fromJson(element.toMap(), element.objectID);
      listModelSite.add(modelSite);
    }
  }

  Future<void> _searchByKeywordFromCache(String keyword) async {
    MyApp.logger.d("캐쉬에서 검색");

    List<String> listKeyword = keyword.split(" ");

    for (String kw in listKeyword) {
      listModelSite.removeWhere((element) => element.name.contains(kw) == false);
    }
  }
}
