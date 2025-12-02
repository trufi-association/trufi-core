class SortedList<T> {
  final Map<String, T> _map = {};
  final List<T> _sortedList = [];
  final int Function(T, T) compare;
  final String Function(T) getId;

  SortedList({required this.compare, required this.getId});

  void add(T item, {bool replace = false}) {
    String id = getId(item);

    if (_map.containsKey(id)) {
      if (replace) {
        _removeById(id);
      } else {
        return;
      }
    }

    _map[id] = item;
    _insertSorted(item);
  }

  void _insertSorted(T item) {
    int index = _sortedList.indexWhere((element) => compare(item, element) < 0);
    if (index == -1) {
      _sortedList.add(item);
    } else {
      _sortedList.insert(index, item);
    }
  }

  void remove(String id) {
    if (_map.containsKey(id)) {
      _removeById(id);
    }
  }

  void _removeById(String id) {
    T? item = _map.remove(id);
    if (item != null) {
      _sortedList.remove(item);
    }
  }

  List<T> get items => List.unmodifiable(_sortedList);
  bool contains(String id) => _map.containsKey(id);
  int get length => _sortedList.length;
  void clear() {
    _map.clear();
    _sortedList.clear();
  }
}
