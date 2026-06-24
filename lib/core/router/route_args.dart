class AnalysisArgs {
  final List<dynamic> quizAnswers;

  /// Local file path of the captured face image.
  /// null when camera failed — triggers quiz-only fallback.
  final String? imagePath;

  const AnalysisArgs({required this.quizAnswers, this.imagePath});
}
