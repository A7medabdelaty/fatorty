class CustomDatabaseException implements Exception {
  final String message;
  final String code;
  final dynamic details;
  final StackTrace? stackTrace;

  CustomDatabaseException(
    this.message, {
    this.code = '',
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    String errorMessage = 'خطأ في قاعدة البيانات: $message';
    if (code.isNotEmpty) {
      errorMessage += ' (رمز الخطأ: $code)';
    }
    if (details != null) {
      errorMessage += '\nالتفاصيل: $details';
    }
    if (stackTrace != null) {
      errorMessage += '\nمسار التنفيذ: $stackTrace';
    }
    return errorMessage;
  }
}

class DatabaseErrorCodes {
  // أخطاء عامة
  static const String databaseClosed = 'DATABASE_CLOSED';
  static const String invalidData = 'INVALID_DATA';
  static const String notFound = 'NOT_FOUND';
  static const String connectionError = 'CONNECTION_ERROR';
  static const String timeout = 'TIMEOUT';

  // أخطاء القيود
  static const String duplicateEntry = 'DUPLICATE_ENTRY';
  static const String foreignKeyViolation = 'FOREIGN_KEY_VIOLATION';
  static const String uniqueConstraint = 'UNIQUE_CONSTRAINT';
  static const String notNullConstraint = 'NOT_NULL_CONSTRAINT';

  // أخطاء العمليات
  static const String insertError = 'INSERT_ERROR';
  static const String updateError = 'UPDATE_ERROR';
  static const String deleteError = 'DELETE_ERROR';
  static const String queryError = 'QUERY_ERROR';

  // أخطاء التحقق
  static const String validationError = 'VALIDATION_ERROR';
  static const String invalidFormat = 'INVALID_FORMAT';
  static const String invalidType = 'INVALID_TYPE';

  // أخطاء الأمان
  static const String unauthorized = 'UNAUTHORIZED';
  static const String permissionDenied = 'PERMISSION_DENIED';

  // أخطاء الأداء
  static const String performanceError = 'PERFORMANCE_ERROR';
  static const String resourceExhausted = 'RESOURCE_EXHAUSTED';
}
