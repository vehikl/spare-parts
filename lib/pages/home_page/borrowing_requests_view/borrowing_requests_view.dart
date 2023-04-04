import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_request_action_button.dart';
import 'package:spare_parts/pages/home_page/borrowing_requests_view/borrowing_request_list_item.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/constants.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';

class BorrowingRequestsView extends StatelessWidget {
  const BorrowingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();
    final auth = context.watch<FirebaseAuth>();
    final isAdmin = context.watch<UserRole>() == UserRole.admin;

    return Center(
      child: StreamBuilder<List<BorrowingRequest>>(
        stream: firestoreService.getBorrowingRequestsStream(
          whereIssuerIs: isAdmin ? null : auth.currentUser?.uid,
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
            return EmptyListState(
                message: "You haven't requested any items yet...");
          }

          return ListView.builder(
            itemCount: borrowingRequests.length,
            itemBuilder: (context, index) {
              return BorrowingRequestListItem(
                borrowingRequest: borrowingRequests[index],
              );
            },
          );
        },
      ),
    );
  }
}
