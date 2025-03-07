import {UserRecord} from 'firebase-admin/lib/auth/user-record'
import {associateUserWithExistingItems} from './associateUserWithExistingItems'
import {deleteAllData} from './utils/testUtils'
import {initializeApp} from 'firebase-admin/app'
import {getFirestore} from 'firebase-admin/firestore'

initializeApp({projectId: 'vehikl-spare-parts'})

describe('associateUserWithExistingItems', () => {
  beforeEach(deleteAllData)

  it('associates item with existing users', async () => {
    const userEmail = 'me@example.com'
    const user = {
      uid: 'myUID',
      email: userEmail,
      displayName: 'Me',
      photoURL: 'some-photo-url',
    } as UserRecord

    const itemDocRef = await getFirestore().collection('items').add({
      name: 'MyItem',
      borrower: {
        email: userEmail,
        name: 'Some other name',
      },
    })

    await associateUserWithExistingItems(user)

    const actualItem = await itemDocRef.get()
    expect(actualItem.data()).toEqual(expect.objectContaining({
      borrower: expect.objectContaining({
        uid: user.uid,
        name: user.displayName,
        photoURL: user.photoURL,
      }),
    }))
  })
})
