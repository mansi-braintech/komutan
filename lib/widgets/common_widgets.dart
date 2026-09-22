import 'package:flutter/material.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';
import 'package:komutan/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class StatusBadge extends StatelessWidget {
  final TripStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    String label;
    switch (status) {
      case TripStatus.inTransit:
        bg = AppColors.tagInTransitBg;
        text = AppColors.inTransit;
        label = 'In Transit';
        break;
      case TripStatus.delivered:
        bg = AppColors.tagDeliveredBg;
        text = AppColors.tagDeliveredText;
        label = 'Delivered';
        break;
      default:
        bg = AppColors.tagAssignedBg;
        text = AppColors.secondary;
        label = 'Assigned';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class AddressRow extends StatelessWidget {
  final bool isPickup;
  final String city;
  final String address;
  const AddressRow({super.key, required this.isPickup, required this.city, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.circle, size: 10, color: isPickup ? AppColors.pickupGreen : AppColors.primary),
            if (!isPickup) Container(width: 2, height: 0, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isPickup ? 'Pickup' : 'Delivery', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(
                city,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
              ),
              Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class NavigateCallButtons extends StatelessWidget {
  final VoidCallback? onNavigate;
  final VoidCallback? onCall;
  const NavigateCallButtons({super.key, this.onNavigate, this.onCall});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.navigation_outlined, size: 18),
            label: const Text('Navigate'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Call Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkgrey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw Exception('Could not launch phone dialer');
    }
  }
}

class TripInfoChips extends StatelessWidget {
  final String cargoType;
  final String weight;
  final String date;
  const TripInfoChips({super.key, required this.cargoType, required this.weight, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chip(Image.asset("assets/icons/Frame.png"), cargoType),
        const SizedBox(width: 8),
        _chip(Image.asset("assets/icons/Frame1.png"), weight),
        const SizedBox(width: 8),
        _chip(Image.asset("assets/icons/Frame2.png"), 'May 5'),
      ],
    );
  }

  Widget _chip(icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool collapsible;
  const SectionCard({super.key, required this.title, required this.child, this.collapsible = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        trailing: collapsible ? const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary) : const SizedBox.shrink(),
        children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: child)],
      ),
    );
  }
}

/// Trip timeline with a slow, distinct "drop 1 → 2 → 3 → 4" reveal: each
/// numbered stop bounces down onto the track one at a time (with a real
/// multi-bounce landing, not just a fade), leaves a little impact ripple,
/// and the line fills in like travel time between stops. The current
/// in-progress stop shows an animated delivery icon, like Zomato/Swiggy.
class TimelineWidget extends StatefulWidget {
  final List<TimelineEvent> events;
  const TimelineWidget({super.key, required this.events});

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> with TickerProviderStateMixin {
  AnimationController? _revealController;
  late AnimationController _pulseController;
  List<Animation<double>> _dotDrops = []; // bounce-drop progress (translate + scale)
  List<Animation<double>> _dotFades = []; // label/dot fade-in
  List<Animation<double>> _lineFills = []; // connecting line fill
  List<double> _dropEndFractions = []; // where each drop lands, for the ripple

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
    _setupReveal();
  }

  @override
  void didUpdateWidget(covariant TimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCompleted = oldWidget.events.where((e) => e.completed).length;
    final newCompleted = widget.events.where((e) => e.completed).length;
    if (oldWidget.events.length != widget.events.length || oldCompleted != newCompleted) {
      _setupReveal();
    }
  }

  void _setupReveal() {
    _revealController?.dispose();

    final count = widget.events.length;

    // Slow, clearly-countable cadence: each stop takes perStepMs to drop
    // and bounce into place, then there's a travelMs pause (during which
    // the line behind it fills in) before the next stop drops — so it
    // reads as a deliberate "1 ... 2 ... 3 ... 4" rather than a quick blur.
    const perStepMs = 550;
    const travelMs = 550;
    const stepGap = perStepMs + travelMs;
    final totalMs = (stepGap * (count - 1)) + perStepMs + 450;

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    final drops = <Animation<double>>[];
    final fades = <Animation<double>>[];
    final fills = <Animation<double>>[];
    final dropEndFractions = <double>[];

    for (int i = 0; i < count; i++) {
      final dropStartMs = i * stepGap;
      final dropEndMs = dropStartMs + perStepMs;
      final fadeEndMs = dropStartMs + 150;
      final lineStartMs = dropEndMs;
      final lineEndMs = dropEndMs + travelMs;

      final dropStart = (dropStartMs / totalMs).clamp(0.0, 1.0);
      final dropEnd = (dropEndMs / totalMs).clamp(0.0, 1.0);
      final fadeEnd = (fadeEndMs / totalMs).clamp(0.0, 1.0);
      final lineStart = (lineStartMs / totalMs).clamp(0.0, 1.0);
      final lineEnd = (lineEndMs / totalMs).clamp(0.0, 1.0);

      dropEndFractions.add(dropEnd);

      // bounceOut gives a literal "drop and settle with a couple of small
      // bounces" motion — much more distinctive than a simple ease-in.
      drops.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(dropStart, dropEnd, curve: Curves.bounceOut),
          ),
        ),
      );
      fades.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(dropStart, fadeEnd, curve: Curves.easeOut),
          ),
        ),
      );
      fills.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(lineStart, lineEnd, curve: Curves.easeInOut),
          ),
        ),
      );
    }

    setState(() {
      _revealController = controller;
      _dotDrops = drops;
      _dotFades = fades;
      _lineFills = fills;
      _dropEndFractions = dropEndFractions;
    });

    controller.forward(from: 0);
  }

  @override
  void dispose() {
    _revealController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events;
    final revealController = _revealController;
    if (revealController == null) return const SizedBox();

    final activeIndex = events.indexWhere((e) => !e.completed);

    return AnimatedBuilder(
      animation: Listenable.merge([revealController, _pulseController]),
      builder: (context, _) {
        return Column(
          children: List.generate(events.length, (i) {
            final event = events[i];
            final isLast = i == events.length - 1;
            final isActive = i == activeIndex;
            final dropValue = _dotDrops[i].value;
            final fadeValue = _dotFades[i].value.clamp(0.0, 1.0);
            final fillValue = _lineFills[i].value.clamp(0.0, 1.0);
            // How far past landing we are, 0→1 over a short window — drives
            // the one-shot impact ripple right after each stop drops in.
            final rippleValue = ((revealController.value - _dropEndFractions[i]) / 0.06).clamp(0.0, 1.0);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        _buildAnimatedDot(stepNumber: i + 1, event: event, isActive: isActive, dropValue: dropValue, fadeValue: fadeValue, rippleValue: rippleValue),
                        if (!isLast)
                          Expanded(
                            // Two stacked, flex-sized segments (green on top,
                            // grey below) instead of a Stack with an
                            // infinite-height child — this stays safe under
                            // the IntrinsicHeight above, which needs every
                            // descendant to report a finite intrinsic height.
                            child: Column(
                              children: [
                                Expanded(
                                  flex: event.completed ? (fillValue * 1000).round().clamp(1, 999) : 1,
                                  child: Container(width: 2, color: event.completed ? AppColors.successLight : AppColors.timelinePending),
                                ),
                                Expanded(
                                  flex: event.completed ? (1000 - (fillValue * 1000).round().clamp(1, 999)) : 999,
                                  child: Container(width: 2, color: AppColors.timelinePending),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Opacity(
                        opacity: fadeValue,
                        child: Transform.translate(
                          offset: Offset((1 - fadeValue) * 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: event.completed ? AppColors.textPrimary : (isActive ? AppColors.primary : AppColors.textSecondary),
                                ),
                              ),
                              if (event.dateTime != null) Text(event.dateTime!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              if (isActive)
                                const Text(
                                  'In progress...',
                                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildAnimatedDot({
    required int stepNumber,
    required TimelineEvent event,
    required bool isActive,
    required double dropValue,
    required double fadeValue,
    required double rippleValue,
  }) {
    // "Drop" the dot in from above with a real multi-bounce landing
    // (bounceOut), a growing pop (easeOutBack) and a tiny settle wobble —
    // three curves layered on the same drop progress for a richer feel
    // than a single fade/scale.
    final t = dropValue.clamp(0.0, 1.0);
    final dropOffsetY = (1 - t) * -46;
    final scale = Curves.easeOutBack.transform(t).clamp(0.0, 1.4);
    final wobble = (1 - t) * (stepNumber.isEven ? 0.22 : -0.22);

    // Content inside the dot: a running step number until it's reached,
    // a truck for the one currently in progress, a check once it's done.
    Widget inner;
    if (event.completed) {
      inner = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (isActive) {
      final wiggle = (0.5 - (_pulseController.value - 0.5).abs()) * 6; // -3..3..-3 px
      inner = Transform.translate(
        offset: Offset(wiggle, 0),
        child: const Icon(Icons.local_shipping, size: 14, color: Colors.white),
      );
    } else {
      inner = Text(
        '$stepNumber',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      );
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isActive) _buildPulseRing(),
          // One-shot impact ripple right after landing.
          if (rippleValue > 0 && rippleValue < 1)
            Transform.scale(
              scale: 1.0 + rippleValue * 1.4,
              child: Opacity(
                opacity: (1 - rippleValue) * 0.55,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: event.completed ? AppColors.successLight : AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          Opacity(
            opacity: fadeValue,
            child: Transform.translate(
              offset: Offset(0, dropOffsetY),
              child: Transform.rotate(
                angle: wobble,
                child: Transform.scale(
                  scale: scale <= 0 ? 0.001 : scale,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: event.completed ? AppColors.successLight : (isActive ? AppColors.primary : Colors.white),
                      border: Border.all(color: event.completed ? AppColors.successLight : (isActive ? AppColors.primary : AppColors.timelinePending), width: 2),
                      boxShadow: isActive || event.completed ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))] : null,
                    ),
                    child: inner,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A soft ripple that expands and fades around the currently active step,
  /// similar to the "order in progress" pulse used by Zomato/Swiggy.
  Widget _buildPulseRing() {
    final t = _pulseController.value;
    final scale = 1.0 + t * 1.1;
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.4;
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  const PrimaryButton({super.key, required this.label, this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
