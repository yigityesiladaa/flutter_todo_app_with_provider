import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:todo_app_with_riverpod/models/cat_fact_model.dart';

final httpClientProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://catfact.ninja/'));
});

final catFactsProvider = FutureProvider.autoDispose
    .family<List<CatFactModel>, Map<String, dynamic>>(
        (ref, parametreMapi) async {
  final _dio = ref.watch(httpClientProvider);
  /*  final _result =
      await _dio.get('facts', queryParameters: {
        'limit': parametreMapi['limit'],
        'max_length': parametreMapi['max_length']
      }); */

  final _result = await _dio.get('facts', queryParameters: parametreMapi);
  ref.keepAlive();

  List<Map<String, dynamic>> _mapData = List.from(_result.data['data']);
  List<CatFactModel> _catFactList =
      _mapData.map((e) => CatFactModel.fromMap(e)).toList();
  return _catFactList;
});

class FutureProviderExample extends ConsumerWidget {
  const FutureProviderExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var _liste =
        ref.watch(catFactsProvider(const {'limit': 6, 'max_length': 30}));
    return Scaffold(
      body: SafeArea(
        child: _liste.when(
          data: (liste) {
            return ListView.builder(
              itemCount: liste.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(liste[index].fact),
                );
              },
            );
          },
          error: (err, stack) {
            return Center(
              child: Text('hata cıktı ${err.toString()}'),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
