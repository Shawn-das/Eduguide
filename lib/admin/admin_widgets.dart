import 'package:eduguide/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';


//  Input field 

Widget buildField(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  bool required = false,
  int maxLines = 1,
  TextInputType type = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: type,
      decoration: buildDecoration(label, icon),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
    ),
  );
}

//  Two-column row

Widget buildFieldRow(List<Widget> children) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children
        .map((c) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: c == children.last ? 0 : 8),
                child: c,
              ),
            ))
        .toList(),
  );
}

//Input decoration

InputDecoration buildDecoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPrimary, size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );

//  Section header 

Widget buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
                color: kPrimary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: kPrimary)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: kPrimary.withOpacity(0.15))),
        ],
      ),
    );

// Switch tile 

Widget buildSwitchTile(String label, bool value, ValueChanged<bool> onChanged) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        dense: true,
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        value: value,
        activeColor: kPrimary,
        onChanged: onChanged,
      ),
    );

//Confirm delete dialog

Future<bool> showConfirmDialog(
    BuildContext context, String title, String content) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) ??
      false;
}

//  Stat chip 

class StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const StatChip(this.label, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kAccent, size: 16),
            const SizedBox(width: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      );
}

//  Edit / Delete button 

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ActionBtn(this.icon, this.color, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      );
}

//  Badge chip 

class BadgeChip extends StatelessWidget {
  final String text;
  final Color color;
  const BadgeChip(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 10)),
      );
}

//  Empty state 

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;
  const EmptyState(this.message, this.icon, {super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black12),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: Colors.black38, fontSize: 16)),
            if (onRefresh != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
}
