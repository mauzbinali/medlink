enum DoctorApprovalStatus { pending, approved, suspended, rejected }

extension DoctorApprovalStatusLabel on DoctorApprovalStatus {
  String get label {
    return switch (this) {
      DoctorApprovalStatus.pending => 'Pending',
      DoctorApprovalStatus.approved => 'Approved',
      DoctorApprovalStatus.suspended => 'Suspended',
      DoctorApprovalStatus.rejected => 'Rejected',
    };
  }
}
