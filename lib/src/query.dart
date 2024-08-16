final class Query {
  
  const Query(this.querys);

  final Map<String, String> querys;

  String get toURLParams {

    if (querys.isEmpty) return '';

    return querys.entries.fold('', (previousValue, entry) {
      if (previousValue.isNotEmpty) {
        return '$previousValue&${entry.key}=${entry.value}';
      } else {
        return '?${entry.key}=${entry.value}';
      }
    });
    
  }

}