import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../controllers/service_controller.dart';
import '../../../models/service.dart';
import 'service_form_screen.dart';
import '../../../widgets/shared/glass_button.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  const ServiceCard({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'fcfa',
      decimalDigits: 0,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          // Ouvre le formulaire d'édition sauf si clic sur le menu
          Get.dialog(ServiceFormScreen(service: widget.service));
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(_hovering ? 0.10 : 0.07)
                : Colors.white.withOpacity(_hovering ? 0.45 : 0.35),
            borderRadius: AppRadius.radiusMD,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.10),
                blurRadius: _hovering ? 18 : 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: _hovering
                  ? AppColors.primary.withOpacity(0.25)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusMD,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.service.name,
                                style: AppTextStyles.h3.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.service.description != null &&
                                  widget.service.description!.isNotEmpty) ...[
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.service.description!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.85)
                                        : AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppColors.textSecondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Theme.of(context).cardColor.withOpacity(0.95),
                          elevation: 8,
                          onSelected: (String value) {
                            switch (value) {
                              case 'edit':
                                Get.dialog(
                                    ServiceFormScreen(service: widget.service));
                                break;
                              case 'delete':
                                Get.dialog(
                                  AlertDialog(
                                    title: Text('Confirmation'),
                                    content: Text(
                                      'Voulez-vous vraiment supprimer le service "${widget.service.name}" ?',
                                    ),
                                    actions: [
                                      GlassButton(
                                        label: 'Annuler',
                                        variant: GlassButtonVariant.secondary,
                                        onPressed: () => Get.back(),
                                      ),
                                      GlassButton(
                                        label: 'Supprimer',
                                        icon: Icons.delete,
                                        variant: GlassButtonVariant.error,
                                        onPressed: () {
                                          Get.back();
                                          controller
                                              .deleteService(widget.service.id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      size: 20, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Modifier',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 20, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Supprimer',
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(widget.service.price),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
