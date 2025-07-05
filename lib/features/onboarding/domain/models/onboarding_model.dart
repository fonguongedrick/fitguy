class OnboardingItem {
  final String title;
  final String? subtitle;
  final String? stepText;
  final List<String>? options;
  final String? timeDisplay;
  final String? nextButtonText;
  final String networkImageUrl;

  OnboardingItem({
    required this.title,
    this.subtitle,
    this.stepText,
    this.options,
    this.timeDisplay,
    this.nextButtonText,
    required this.networkImageUrl,
  });
}