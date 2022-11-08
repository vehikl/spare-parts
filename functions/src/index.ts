import * as functions from 'firebase-functions'

import * as admin from 'firebase-admin'

admin.initializeApp()

export const getUsers = functions.https.onCall(async (data, context) => {
  const userListResult = await admin.auth().listUsers()
  const users = userListResult.users

  return users.map((user) => ({
    id: user.uid,
    name: user.displayName,
  }))
})

export const setAdmin = functions.https.onCall(async (data, context) => {
  const uid = data.uid

  if (!uid) throw new Error('The `uid` parameter is required')

  return await admin.auth().setCustomUserClaims(uid, {
    role: 'admin',
  })
})
