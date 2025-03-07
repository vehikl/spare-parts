import {getFirestore} from 'firebase-admin/firestore'
import {CustomUser} from './types/customUser'

export async function syncItemBorrowersWithUser(userData: CustomUser): Promise<void> {
  const itemsWithRelatedBorrowers = await getFirestore()
      .collection('items')
      .where('borrower.uid', '==', userData.uid)
      .get()
  for (const itemDocQuerySnaps of itemsWithRelatedBorrowers.docs) {
    await itemDocQuerySnaps.ref.update({
      borrower: userData,
    })
  }
}
