class PageInfo {
  final bool? hasNextPage;
  final bool? hasPreviousPage;
  final String? startCursor;
  final String? endCursor;

  const PageInfo({
    this.hasNextPage,
    this.hasPreviousPage,
    this.startCursor,
    this.endCursor,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        hasNextPage: json['hasNextPage'] as bool?,
        hasPreviousPage: json['hasPreviousPage'] as bool?,
        startCursor: json['startCursor'].toString(),
        endCursor: json['endCursor'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'hasNextPage': hasNextPage,
        'hasPreviousPage': hasPreviousPage,
        'startCursor': startCursor,
        'endCursor': endCursor,
      };
}
