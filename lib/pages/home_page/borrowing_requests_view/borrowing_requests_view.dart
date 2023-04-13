import 'package:flutter/material.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/filtered_borrowing_requests_section.dart';

class BorrowingRequestsView extends StatelessWidget {
  const BorrowingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: FilteredBorrowingRequestsSection(showProcessed: false)),
        Divider(),
        Expanded(child: FilteredBorrowingRequestsSection(showProcessed: true)),
      ],
    );
  }
}
