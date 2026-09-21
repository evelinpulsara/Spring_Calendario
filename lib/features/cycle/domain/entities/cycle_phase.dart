/// The four simplified phases of the menstrual cycle.
enum CyclePhase { menstrual, follicular, ovulation, luteal }

extension CyclePhaseInfo on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual phase';
      case CyclePhase.follicular:
        return 'Follicular phase';
      case CyclePhase.ovulation:
        return 'Ovulation phase';
      case CyclePhase.luteal:
        return 'Luteal phase';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'A good time to rest, hydrate and be gentle with yourself.';
      case CyclePhase.follicular:
        return 'Energy often rises in this phase. Great for planning and new routines.';
      case CyclePhase.ovulation:
        return 'Estimated fertile peak of your cycle.';
      case CyclePhase.luteal:
        return 'Some people notice premenstrual symptoms. Track how you feel.';
    }
  }
}
