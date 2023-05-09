import { UserRecord } from "firebase-functions/v1/auth"
import { db } from "./admin"

export async function associateUserWithExistingItems(user: UserRecord) {
    const itemsRef = await db
      .collection('items')
      .where('borrower.name', '==', user.displayName)
      .get()

    console.log(`Found ${itemsRef.docs.length} items for ${user.displayName}`)

    for (const item of itemsRef.docs) {
      console.log(`Updating ${item.data().name}`)
      await item.ref.set({
        ...item.data(),
        borrower: {
          uid: user.uid,
          name: user.displayName,
          photoURL: user.photoURL,
        },
      })
    }
}