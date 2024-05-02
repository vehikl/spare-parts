import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_request_list_item.dart';
import 'package:spare_parts/services/repositories/repositories.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';

class FilteredBorrowingRequestsSection extends StatelessWidget {
  final bool showProcessed;
  const FilteredBorrowingRequestsSection({
    super.key,
    required this.showProcessed,
  });

  @override
  Widget build(BuildContext context) {
    final borrowingRequestRepository =
        context.read<BorrowingRequestRepository>();
    final auth = context.watch<FirebaseAuth>();
    final isAdmin = context.watch<UserRole>() == UserRole.admin;

    return StreamBuilder<List<BorrowingRequest>>(
      stream: borrowingRequestRepository.getBorrowingRequestsStream(
        whereIssuerIs: isAdmin ? null : auth.currentUser?.uid,
        processed: showProcessed,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorContainer(error: snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final borrowingRequests = snapshot.data!;

        if (borrowingRequests.isEmpty) {
          final message = showProcessed
              ? "No processed requests found..."
              : "You haven't requested any items yet...";

          return EmptyListState(message: message);
        }

        return ListView.builder(
          itemCount: borrowingRequests.length,
          itemBuilder: (context, index) {
            return BorrowingRequestListItem(
              borrowingRequest: borrowingRequests[index],
              showOptions: !showProcessed,
            );
          },
        );
      },
    );
  }
}
