import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:kins_fleet_drivers/core/l10n/locale_provider.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/shifts/models/bus.dart';
import 'package:kins_fleet_drivers/features/shifts/models/shift_assignment.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_provider.dart';
import 'package:kins_fleet_drivers/features/shifts/shifts_repository.dart';
import 'package:kins_fleet_drivers/features/shifts/widgets/shift_status_badge.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:kins_fleet_drivers/widgets/loading_overlay.dart';

class ShiftDetailScreen extends StatefulWidget {
  const ShiftDetailScreen({super.key, required this.shiftId});

  final String shiftId;

  @override
  State<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends State<ShiftDetailScreen> {
  ShiftAssignment? _assignment;
  Bus? _bus;
  bool _isLoading = true;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorKey = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final shiftsProvider = context.read<ShiftsProvider>();
      final repository = context.read<ShiftsRepository>();

      ShiftAssignment? assignment = shiftsProvider.findById(widget.shiftId);
      assignment ??= await repository.fetchShiftById(widget.shiftId);

      if (assignment == null) {
        setState(() {
          _errorKey = 'notFound';
          _isLoading = false;
        });
        return;
      }

      if (assignment.driverId != auth.user?.driverId) {
        setState(() {
          _errorKey = 'accessDenied';
          _isLoading = false;
        });
        return;
      }

      Bus? bus;
      if (assignment.busId.isNotEmpty) {
        bus = await repository.fetchBus(assignment.busId);
      }

      if (!mounted) return;
      setState(() {
        _assignment = assignment;
        _bus = bus;
        _isLoading = false;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _errorKey = 'loadFailed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shiftDetailTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_errorKey != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage(l10n, _errorKey!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            )
          else if (_assignment != null)
            _DetailContent(assignment: _assignment!, bus: _bus),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, String key) => switch (key) {
        'notFound' => l10n.shiftNotFound,
        'accessDenied' => l10n.shiftAccessDenied,
        _ => l10n.shiftLoadFailed,
      };
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.assignment, required this.bus});

  final ShiftAssignment assignment;
  final Bus? bus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = context.watch<LocaleProvider>().dateLocaleTag;
    final parsedDate = DateTime.tryParse('${assignment.date}T00:00:00');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                assignment.shiftName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ShiftStatusBadge(status: assignment.status),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: l10n.shiftSectionService,
          emptyValue: l10n.emptyValue,
          rows: [
            _DetailRow(
              label: l10n.labelDate,
              value: parsedDate != null
                  ? AppDateUtils.formatShortDate(parsedDate, localeTag)
                  : assignment.date,
            ),
            _DetailRow(
              label: l10n.labelTime,
              value: '${assignment.startTime} – ${assignment.endTime}',
            ),
            _DetailRow(
              label: l10n.labelDepartment,
              value: assignment.departmentName,
            ),
            _DetailRow(
              label: l10n.labelDriver,
              value: assignment.driverName,
            ),
            if (assignment.notes.isNotEmpty)
              _DetailRow(label: l10n.labelNotes, value: assignment.notes),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: l10n.shiftSectionBus,
          rows: [
            _DetailRow(label: l10n.labelBusNumber, value: assignment.busNumber),
            _DetailRow(
              label: l10n.labelLicensePlate,
              value: assignment.licensePlate,
            ),
            if (bus != null) ...[
              _DetailRow(label: l10n.labelBrandModel, value: bus!.displayName),
              if (bus!.year.isNotEmpty)
                _DetailRow(label: l10n.labelYear, value: bus!.year),
              _DetailRow(
                label: l10n.labelStatus,
                value: l10n.busStatus(bus!.status),
              ),
              if (bus!.notes.isNotEmpty)
                _DetailRow(label: l10n.labelNotes, value: bus!.notes),
            ],
          ],
          emptyValue: l10n.emptyValue,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.rows,
    this.emptyValue = '—',
  });

  final String title;
  final List<_DetailRow> rows;
  final String emptyValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...rows.map((row) => row.copyWith(emptyValue: emptyValue)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emptyValue = '—',
  });

  final String label;
  final String value;
  final String emptyValue;

  _DetailRow copyWith({String? emptyValue}) {
    return _DetailRow(
      label: label,
      value: value,
      emptyValue: emptyValue ?? this.emptyValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? emptyValue : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
