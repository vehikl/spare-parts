import * as functions from 'firebase-functions'

import * as admin from 'firebase-admin'

admin.initializeApp()

export const deleteIfIncorrectEmail = functions.auth.user().onCreate((user, context) => {
  if (!user.email?.endsWith('@vehikl.com')) {
    console.log(`Deleting user with incorrect email: ${user.email}`);
    return admin.auth().deleteUser(user.uid)
  }
  return null
})

export const getUsers = functions.https.onCall(async (data, context) => {
  const userListResult = await admin.auth().listUsers()
  const users = userListResult.users

  return users.map((user) => ({
    id: user.uid,
    name: user.displayName,
    photoUrl: user.photoURL
  }))
})

export const setAdmin = functions.https.onCall(async (data, context) => {
  const uid = data.uid

  if (!uid) throw new Error('The `uid` parameter is required')

  return await admin.auth().setCustomUserClaims(uid, {
    role: 'admin',
  })
})
