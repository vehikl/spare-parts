import {UserRecord} from 'firebase-functions/v1/auth'
import {db} from './admin'

export async function associateUserWithUserDocument(user: UserRecord) {
    const matchingUserDocs = await db.collection('users').where('name', '==', user.displayName).get()

    if (matchingUserDocs.empty) {
        // create a user doc
        db.collection('users').add({
            uid: user.uid,
            name: user.displayName,
            photoURL: user.photoURL,
        })
    } else {
        // update the user doc
    }
}