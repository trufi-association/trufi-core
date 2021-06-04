class Node {
  final String id;

  const Node({this.id});

  factory Node.fromJson(Map<String, dynamic> json) => Node(
        id: json['id'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
      };
}
