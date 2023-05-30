import {UserRecord} from 'firebase-functions/v1/auth'
import {db} from './admin'

export async function associateUserWithUserDocument(user: UserRecord) {
    const matchingUserDocs = await db.collection('users').where('name', '==', user.displayName).get()

    if (matchingUserDocs.empty) {
        await db.collection('users').add({
            uid: user.uid,
            name: user.displayName,
            photoURL: user.photoURL,
        })
    } else {
        const existingUserDoc = matchingUserDocs.docs[0]
        await existingUserDoc.ref.update({
            uid: user.uid,
            photoURL: user.photoURL,
        })
    }
}