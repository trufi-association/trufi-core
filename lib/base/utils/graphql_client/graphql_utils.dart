import "package:gql/ast.dart";

DocumentNode addFragments(DocumentNode doc, List<DocumentNode> fragments) {
  final newDefinitions = Set<DefinitionNode>.from(doc.definitions);
  for (final frag in fragments) {
    newDefinitions.addAll(frag.definitions);
  }
  return DocumentNode(definitions: newDefinitions.toList(), span: doc.span);
}
