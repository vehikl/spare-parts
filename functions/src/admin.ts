import * as admin from 'firebase-admin'

export const firebaseApp = admin.initializeApp()
export const db = firebaseApp.firestore()