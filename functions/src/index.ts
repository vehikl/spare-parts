import * as functions from 'firebase-functions'

import * as admin from 'firebase-admin'

admin.initializeApp()

export const deleteIfIncorrectEmail = functions.auth
    .user()
    .onCreate((user, context) => {
      if (!user.email?.endsWith('@vehikl.com')) {
        console.log(`Deleting user with incorrect email: ${user.email}`)
        return admin.auth().deleteUser(user.uid)
      }
      return null
    })

export const associateWithExistingItems = functions.auth
    .user()
    .onCreate(async (user, context) => {
      const db = admin.firestore()
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
      return null
    })


export const getUsers = functions.https.onCall(async (data, context) => {
  const userListResult = await admin.auth().listUsers()
  const users = userListResult.users

  return users.map((user) => ({
    id: user.uid,
    name: user.displayName,
    photoUrl: user.photoURL,
    role: user.customClaims?.role,
  }))
})

export const setAdmins = functions.https.onCall(async (data, context) => {
  const uids = data.uids as string[]

  if (!uids) throw new Error('The `uids` parameter is required')

  const userListResult = await admin.auth().listUsers()
  const users = userListResult.users

  for (const user of users) {
    await admin.auth().setCustomUserClaims(user.uid, {
      role: uids.includes(user.uid) ? 'admin' : 'user',
    })
  }

  return null
})
