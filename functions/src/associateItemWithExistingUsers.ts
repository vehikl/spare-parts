import {QueryDocumentSnapshot} from 'firebase-functions/v1/firestore'
import {getAuth} from 'firebase-admin/auth'

export async function associateItemWithExistingUsers(
    item: any,
    itemSnap: QueryDocumentSnapshot
) {
  const userListResult = await getAuth().listUsers()
  const users = userListResult.users

  const borrower = users.find((user) => user.displayName === item.borrower?.name)

  if (borrower) {
    console.log(`Assigning "${item.name}" to ${borrower.displayName}`)
    itemSnap.ref.update({
      borrower: {uid: borrower.uid, name: borrower.displayName},
    })
  }
}
