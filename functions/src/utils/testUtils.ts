import {CollectionReference, getFirestore} from 'firebase-admin/firestore'

export async function deleteAllData() {
  const collections = await getFirestore().listCollections()

  for (const collectionRef of collections) {
    await deleteCollection(collectionRef)
  }
}

async function deleteCollection(colRef: CollectionReference) {
  const docs = await colRef.listDocuments()

  for (const docRef of docs) {
    const subCollections = await docRef.listCollections()
    for (const subColRef of subCollections) {
      await deleteCollection(subColRef)
    }
  }
}
