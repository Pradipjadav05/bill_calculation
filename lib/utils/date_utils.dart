String formatBillMonth(DateTime start, DateTime end) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final startMonth = months[start.month - 1];
  final endMonth = months[end.month - 1];

  if (start.year == end.year) {
    if (start.month == end.month) {
      return '$startMonth ${start.year}';
    }
    return '$startMonth to $endMonth ${start.year}';
  }

  return '$startMonth ${start.year} to $endMonth ${end.year}';
}
