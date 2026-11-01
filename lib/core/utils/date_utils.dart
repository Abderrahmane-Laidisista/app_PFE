/// Clinical date formatting utilities.
class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    final dateStr = formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$dateStr $hour:$minute';
  }
}
