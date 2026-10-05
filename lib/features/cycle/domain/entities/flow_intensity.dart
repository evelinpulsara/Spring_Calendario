/// How heavy the menstrual flow is on a given day.
enum FlowIntensity { none, light, medium, heavy }

extension FlowIntensityLabel on FlowIntensity {
  String get label {
    switch (this) {
      case FlowIntensity.none:
        return 'None';
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.medium:
        return 'Medium';
      case FlowIntensity.heavy:
        return 'Heavy';
    }
  }
}
