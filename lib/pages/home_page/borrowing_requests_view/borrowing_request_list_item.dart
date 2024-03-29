import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_request_action_button.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';

class BorrowingRequestListItem extends StatelessWidget {
  final BorrowingRequest borrowingRequest;
  final bool showOptions;

  const BorrowingRequestListItem({
    super.key,
    required this.borrowingRequest,
    this.showOptions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserRole>() == UserRole.admin;

    return ListTile(
      leading: Icon(itemTypes[borrowingRequest.item.type]!),
      title: Text(borrowingRequest.item.name ?? borrowingRequest.item.id),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isAdmin
              ? Text(
                  '${borrowingRequest.issuer.name!} | ${formatDate(borrowingRequest.createdAt!)}')
              : Text(formatDate(borrowingRequest.createdAt!)),
          if (borrowingRequest.response != null)
            Text(
              '${borrowingRequest.response!.approved ? 'Approved' : 'Denied'} by ${borrowingRequest.response!.decisionMaker.name!}',
              style: TextStyle(
                  color: borrowingRequest.response!.approved
                      ? Colors.green
                      : Colors.red),
            )
        ],
      ),
      trailing: showOptions
          ? BorrowingRequestActionsButton(borrowingRequest: borrowingRequest)
          : null,
    );
  }
}
