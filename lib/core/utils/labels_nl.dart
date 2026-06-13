/// Dutch status and enum labels for the driver app.
abstract final class LabelsNl {
  static const statusActive = 'Actief';
  static const statusInactive = 'Inactief';
  static const statusUnavailable = 'Niet beschikbaar';

  static const shiftScheduled = 'Ingepland';
  static const shiftCompleted = 'Voltooid';
  static const shiftCancelled = 'Geannuleerd';

  static const damageReported = 'Gemeld';
  static const damageConfirmed = 'Bevestigd';
  static const damageRepaired = 'Gerepareerd';

  static const severityLow = 'Laag';
  static const severityMedium = 'Gemiddeld';
  static const severityHigh = 'Hoog';

  static String userStatus(String? status) => switch (status) {
        'active' => statusActive,
        'inactive' => statusInactive,
        'unavailable' => statusUnavailable,
        _ => status ?? '—',
      };

  static String shiftStatus(String? status) => switch (status) {
        'scheduled' => shiftScheduled,
        'completed' => shiftCompleted,
        'cancelled' => shiftCancelled,
        _ => status ?? '—',
      };

  static String damageStatus(String? status) => switch (status) {
        'reported' => damageReported,
        'confirmed' => damageConfirmed,
        'repaired' => damageRepaired,
        _ => status ?? '—',
      };

  static String severity(String? value) => switch (value) {
        'low' => severityLow,
        'medium' => severityMedium,
        'high' => severityHigh,
        _ => value ?? '—',
      };
}
