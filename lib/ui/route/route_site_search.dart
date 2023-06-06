import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:today_safety/my_app.dart';
import 'package:today_safety/service/provider/provider_site_search.dart';

class RouteSiteSearch extends StatefulWidget {
  const RouteSiteSearch({Key? key}) : super(key: key);

  @override
  State<RouteSiteSearch> createState() => _RouteSiteSearchState();
}

class _RouteSiteSearchState extends State<RouteSiteSearch> {
  TextEditingController textEditingController = TextEditingController();
  ProviderSiteSearch providerSiteSearch = ProviderSiteSearch();

  @override
  void initState() {
    if (Get.arguments is Map) {
      var keyword = Get.arguments['keyword'];
      if (keyword != null && keyword is String && keyword.isNotEmpty) {
        textEditingController.text = keyword;
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: providerSiteSearch),
          ],
          builder: (context, child) => Consumer<ProviderSiteSearch>(
            builder: (context, value, child) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(hintText: '검색어를 입력해라'),
                        onChanged: providerSiteSearch.handleInput,
                      ),
                    ),
                    value.isSearching
                        ? SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(),
                          )
                        : const Icon(
                            Icons.search,
                            size: 48,
                          ),
                  ],
                ),
                //Expanded(child: ListView.builder(itemBuilder: itemBuilder))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
