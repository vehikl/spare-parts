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
