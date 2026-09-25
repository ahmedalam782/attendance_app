import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/permission_confirmation_dialog.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../data/utils/csv_roster_parser.dart';
import '../../../domain/entities/csv_student_entry.dart';
import '../../view_model/cubit/enrollment_cubit.dart';
import '../../view_model/cubit/enrollment_state.dart';

class CsvImportSheet extends StatefulWidget {
  const CsvImportSheet({
    super.key,
    required this.programId,
  });

  final String programId;

  static Future<void> show(BuildContext context, {required String programId}) {
    final cubit = context.read<EnrollmentCubit>();
    return showAppSheet(
      context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CsvImportSheet(programId: programId),
      ),
    );
  }

  @override
  State<CsvImportSheet> createState() => _CsvImportSheetState();
}

class _CsvImportSheetState extends State<CsvImportSheet> {
  String? _fileName;
  List<CsvStudentEntry> _parsedStudents = [];
  bool _isParsing = false;

  int get _validCount => _parsedStudents.where((s) => s.isValid).length;
  int get _invalidCount => _parsedStudents.where((s) => !s.isValid).length;

  Future<void> _downloadTemplate() async {
    try {
      const csvContent =
          'name,id\n'
          'Ahmed Mohamed,STU001\n'
          'Sara Ali,STU002\n'
          'Omar Hassan,STU003\n';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/students_template.csv');
      await file.writeAsString(csvContent, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: LocaleKeys.csv_import_download_template.tr(),
        ),
      );

      if (mounted) {
        CustomToast(
          context: context,
          header: LocaleKeys.csv_import_template_saved_success.tr(),
          type: ToastificationType.success,
        ).showToast();
      }
    } catch (_) {
      // Ignore share cancellation or non-fatal errors
    }
  }

  Future<void> _pickFile() async {
    final confirmed =
        await PermissionConfirmationDialog.showFilePermission(context);
    if (!confirmed || !mounted) return;

    try {
      setState(() => _isParsing = true);
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (files.isEmpty) {
        setState(() => _isParsing = false);
        return;
      }

      final file = files.first;
      _fileName = file.name;

      final bytes = await file.readAsBytes();
      const parser = CsvRosterParser();
      _parsedStudents = parser.parseBytes(bytes);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  Future<void> _submitImport() async {
    if (_validCount == 0) return;

    final imported = await context.read<EnrollmentCubit>().importStudentsFromCsv(
          programId: widget.programId,
          students: _parsedStudents,
        );

    if (!mounted) return;

    if (imported > 0) {
      Navigator.of(context).pop();
      CustomToast(
        context: context,
        header: LocaleKeys.csv_import_import_success.tr(
          namedArgs: {'count': imported.toString()},
        ),
        type: ToastificationType.success,
      ).showToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.csv_import_title.tr(),
                            style: 18.bold.copyWith(color: AppColors.slate900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LocaleKeys.csv_import_subtitle.tr(),
                            style: 12.medium.copyWith(color: AppColors.slate500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_parsedStudents.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: Text(
                          LocaleKeys.csv_import_change_file.tr(),
                          style: 12.bold,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _downloadTemplate,
                        icon: const Icon(Icons.download_rounded, size: 15),
                        label: Text(
                          LocaleKeys.csv_import_download_template.tr(),
                          style: 12.bold,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primaryLight,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.csv_import_format_hint.tr(),
                  style: 11.regular.copyWith(color: AppColors.slate400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Counts summary bar (if file parsed)
          if (_parsedStudents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        LocaleKeys.csv_import_valid_count.tr(
                          namedArgs: {'count': _validCount.toString()},
                        ),
                        style: 11.bold.copyWith(color: AppColors.present),
                      ),
                    ),
                    if (_invalidCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          LocaleKeys.csv_import_invalid_count.tr(
                            namedArgs: {'count': _invalidCount.toString()},
                          ),
                          style: 11.bold.copyWith(color: AppColors.absent),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (_fileName != null)
                      Text(
                        _fileName!,
                        style: 11.medium.copyWith(color: AppColors.slate500),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Preview List
          Expanded(
            child: _isParsing
                ? const Center(child: CircularProgressIndicator())
                : _parsedStudents.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.table_chart_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              LocaleKeys.csv_import_pick_file.tr(),
                              style: 16.bold.copyWith(color: AppColors.slate800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              LocaleKeys.csv_import_sample_template_hint.tr(),
                              textAlign: TextAlign.center,
                              style: 12.regular.copyWith(
                                color: AppColors.slate500,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Template preview card ("TO MAKE IT LIKE THAT")
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.format_list_bulleted_rounded,
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'CSV Template Format (تنسيق القالب المطلوب)',
                                        style: 11.bold.copyWith(color: AppColors.slate700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.slate200),
                                    ),
                                    child: Text(
                                      'name,id\nAhmed Mohamed,STU001\nSara Ali,STU002\nOmar Hassan,STU003',
                                      style: 12.medium.copyWith(
                                        fontFamily: 'monospace',
                                        color: AppColors.slate800,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Two actions: Save/Download Template + Select File
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _downloadTemplate,
                                    icon: const Icon(Icons.file_download_outlined, size: 18),
                                    label: Text(
                                      LocaleKeys.csv_import_download_template.tr(),
                                      style: 12.bold,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickFile,
                                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                                    label: Text(
                                      LocaleKeys.csv_import_pick_file.tr(),
                                      style: 12.bold,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        itemCount: _parsedStudents.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final entry = _parsedStudents[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: entry.isValid
                                    ? AppColors.slate200
                                    : AppColors.absent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  entry.isValid
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.error_outline_rounded,
                                  size: 18,
                                  color: entry.isValid
                                      ? AppColors.present
                                      : AppColors.absent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.name.isNotEmpty
                                            ? entry.name
                                            : '(Empty name)',
                                        style: 13.bold.copyWith(
                                          color: entry.name.isNotEmpty
                                              ? AppColors.slate900
                                              : AppColors.absent,
                                        ),
                                      ),
                                      Text(
                                        entry.id.isNotEmpty
                                            ? entry.id
                                            : '(Empty ID)',
                                        style: 11.medium.copyWith(
                                          color: entry.id.isNotEmpty
                                              ? AppColors.slate500
                                              : AppColors.absent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!entry.isValid && entry.error != null)
                                  Text(
                                    entry.error == 'missing_name'
                                        ? LocaleKeys.csv_import_missing_name.tr()
                                        : LocaleKeys.csv_import_missing_id.tr(),
                                    style: 10.bold.copyWith(
                                      color: AppColors.absent,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Submit button
          if (_parsedStudents.isNotEmpty && _validCount > 0)
            Padding(
              padding: const EdgeInsets.all(20),
              child: BlocBuilder<EnrollmentCubit, EnrollmentState>(
                builder: (context, state) {
                  return CustomButton(
                    title: LocaleKeys.csv_import_submit_button.tr(
                      namedArgs: {'count': _validCount.toString()},
                    ),
                    isLoading: state.isActionLoading,
                    onTap: _submitImport,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
