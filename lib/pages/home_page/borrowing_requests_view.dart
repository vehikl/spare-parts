import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spare_parts/entities/borrowing_request.dart';
import 'package:spare_parts/services/firestore_service.dart';
import 'package:spare_parts/utilities/helpers.dart';
import 'package:spare_parts/widgets/empty_list_state.dart';
import 'package:spare_parts/widgets/error_container.dart';

class BorrowingRequestsView extends StatelessWidget {
  const BorrowingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final auth = context.read<FirebaseAuth>();

    return Center(
      child: StreamBuilder<List<BorrowingRequest>>(
        stream: firestoreService.getBorrowingRequestsStream(
          whereIssuerIs: auth.currentUser?.uid,
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
              var borrowingRequest = borrowingRequests[index];
              return ListTile(
                title: Text(borrowingRequest.item.id),
                subtitle: borrowingRequest.createdAt != null
                    ? Text(formatDate(borrowingRequest.createdAt!))
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
