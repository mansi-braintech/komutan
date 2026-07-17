import 'package:flutter/material.dart';
import 'package:komutan/app/dashboard/trip/trip_model.dart';
import 'package:komutan/utils/app_colors.dart';

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
  const NavigateCallButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
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
            onPressed: () {},
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

class TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;
  const TimelineWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(events.length, (i) {
        final event = events[i];
        final isLast = i == events.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    _buildDot(event.completed),
                    if (!isLast) Expanded(child: Container(width: 2, color: event.completed ? AppColors.successLight : AppColors.timelinePending)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.label,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: event.completed ? AppColors.textPrimary : AppColors.textSecondary),
                      ),
                      if (event.dateTime != null) Text(event.dateTime!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDot(bool completed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? AppColors.successLight : Colors.white,
        border: Border.all(color: completed ? AppColors.successLight : AppColors.timelinePending, width: 2),
      ),
      child: completed ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
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
