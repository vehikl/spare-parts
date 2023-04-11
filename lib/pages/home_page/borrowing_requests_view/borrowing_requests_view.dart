import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/pending_requests_section.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/processed_requests_section.dart';

class BorrowingRequestsView extends StatelessWidget {
  const BorrowingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: PendingRequestsSection()),
        Divider(),
        Expanded(child: ProcessedRequestsSection()),
      ],
    );
  }
}
