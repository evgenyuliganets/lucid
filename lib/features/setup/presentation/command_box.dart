import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/l10n/l10n.dart';

/// A terminal command the user types on a computer, with a copy button.
class CommandBox extends StatelessWidget {
  const CommandBox({super.key, required this.command});

  final String command;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SelectableText(
                command,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.installCopyTooltip,
            icon: const Icon(Icons.copy),
            onPressed: () async {
              final copied = context.l10n.installCopied;
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: command));
              messenger.showSnackBar(SnackBar(content: Text(copied)));
            },
          ),
        ],
      ),
    );
  }
}
