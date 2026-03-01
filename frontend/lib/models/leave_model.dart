class LeaveModel {
  final int id;
  final String studentName;
  final String reason;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final bool parentApproved;
  final bool wardenApproved;
  final String status;
  final String? qrToken;

  LeaveModel({
    required this.id,
    required this.studentName,
    required this.reason,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.parentApproved,
    required this.wardenApproved,
    required this.status,
    this.qrToken,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      studentName: json['student_name'] ?? '',
      reason: json['reason'] ?? '',
      destination: json['destination'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      parentApproved: json['parent_approved'] ?? false,
      wardenApproved: json['warden_approved'] ?? false,
      status: json['status'] ?? 'PENDING',
      qrToken: json['qr_code_token'],
    );
  }
}
