import {initializeApp} from 'firebase-admin/app'
import {getAuth} from 'firebase-admin/auth'
import * as functions from 'firebase-functions/v1'
import {associateItemWithExistingUsers} from './associateItemWithExistingUsers'
import {associateUserWithExistingItems} from './associateUserWithExistingItems'
import {associateUserWithUserDocument} from './associateUserWithUserDocument'
import {incrementItemNameIds} from './incrementItemNameId'
import {syncItemBorrowersWithUser} from './syncItemBorrowersWithUser'
import {CustomUser} from './types/customUser'

initializeApp()

export const deleteIfIncorrectEmail = functions.auth
    .user()
    .beforeCreate(async (user, _) => {
      if (!user.email?.endsWith('@vehikl.com')) {
        console.log(`Deleting user with incorrect email: ${user.email}`)
        await getAuth().deleteUser(user.uid)
      }
    })

export const userCreated = functions.auth
    .user()
    .onCreate(async (user, _) => {
      await associateUserWithUserDocument(user)
      await associateUserWithExistingItems(user)
      return null
    })

export const getUsers = functions.https.onCall(async (_, __) => {
  const userListResult = await getAuth().listUsers()
  const users = userListResult.users

  return users.map((user) => ({
    id: user.uid,
    name: user.displayName,
    photoUrl: user.photoURL,
    role: user.customClaims?.role,
  }))
})

export const setAdmins = functions.https.onCall(async (data, _) => {
  const uids = data.uids as string[]

  if (!uids) throw new Error('The `uids` parameter is required')

  const userListResult = await getAuth().listUsers()
  const users = userListResult.users

  for (const user of users) {
    await getAuth().setCustomUserClaims(user.uid, {
      role: uids.includes(user.uid) ? 'admin' : 'user',
    })
  }

  return null
})

// this is only used for the initial import of the items
export const itemCreated = functions.firestore
    .document('items/{itemId}')
    .onCreate(async (snap, _) => {
      const item = snap.data()

      const itemBorrowerIsIncomplete = item.borrower?.name && !item.borrower?.id
      if (itemBorrowerIsIncomplete) {
        await associateItemWithExistingUsers(item, snap)
      }

      return null
    })

export const itemChanged = functions.firestore
    .document('items/{itemId}')
    .onWrite(async (change, _) => {
      const item = change.after.data()
      const oldItem = change.before.data()

      if (!item) return null

      if (item.name !== oldItem?.name) {
        await incrementItemNameIds(item)
      }

      return null
    })

export const userChanged = functions.firestore
    .document('users/{uid}')
    .onUpdate(async (change, _) => {
      const userData = change.after.data() as CustomUser
      await syncItemBorrowersWithUser(userData)
    })
