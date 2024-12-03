import {initializeApp} from 'firebase-admin/app'
import {getFirestore} from 'firebase-admin/firestore'
import {syncItemBorrowersWithUser} from './syncItemBorrowersWithUser'
import {CustomUser} from './types/customUser'
import {deleteAllData} from './utils/testUtils'

initializeApp({projectId: 'vehikl-spare-parts'})

describe('syncItemBorrowersWithUser', () => {
  beforeEach(deleteAllData)

  it('updates related item borrowers', async () => {
    const user: CustomUser = {
      uid: 'myUID',
      email: 'me@example.com',
      name: 'New Name',
      photoURL: 'some-photo-url',
    }

    const itemDocRef = await getFirestore().collection('items').add({
      name: 'MyItem',
      borrower: {
        ...user,
        email: 'oldEmail',
        name: 'Old Name',
        photoURL: 'old-photo',
      },
    })

    await syncItemBorrowersWithUser(user)

    const actualItem = await itemDocRef.get()
    expect(actualItem.data()).toEqual(expect.objectContaining({
      borrower: user,
    }))
  })

  it('does not update unrelated item borrowers', async () => {
    const user: CustomUser = {
      uid: 'myUID',
      email: 'me@example.com',
      name: 'New Name',
      photoURL: 'some-photo-url',
    }

    const oldItem = {
      name: 'MyItem',
      borrower: {
        uid: 'SomeOtherItem',
        email: 'oldEmail',
        name: 'Old Name',
        photoURL: 'old-photo',
      },
    }
    const itemDocRef = await getFirestore().collection('items').add(oldItem)

    await syncItemBorrowersWithUser(user)

    const actualItem = await itemDocRef.get()
    expect(actualItem.data()).toEqual(expect.objectContaining({
      borrower: oldItem.borrower,
    }))
  })
})
