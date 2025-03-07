import {UserRecord} from 'firebase-functions/v1/auth'
import {getFirestore} from 'firebase-admin/firestore'

export async function associateUserWithUserDocument(user: UserRecord) {
  const matchingUserDocs = await getFirestore().collection('users').where('email', '==', user.email).get()

  if (matchingUserDocs.empty) {
    await getFirestore().collection('users').add({
      uid: user.uid,
      name: user.displayName,
      photoURL: user.photoURL,
      email: user.email,
    })
  } else {
    const existingUserDoc = matchingUserDocs.docs[0]
    await existingUserDoc.ref.update({
      uid: user.uid,
      photoURL: user.photoURL,
      name: user.displayName,
    })
  }
}
