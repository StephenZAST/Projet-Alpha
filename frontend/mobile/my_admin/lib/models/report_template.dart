class ReportTemplate {
  final String id;
  final String name;
  final List<String> columns;
  final Map<String, String> filters;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.columns,
    required this.filters,
  });
}
