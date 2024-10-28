import {getFirestore} from 'firebase-admin/firestore'

export async function incrementItemNameIds(item: any) {
  const newId = item.name.match(/\w+ #(\d+)/)?.[1]
  if (newId) {
    const highestNameIdsDoc = await getFirestore()
        .collection('meta')
        .doc('itemNameIds')
        .get()
    const highestNameIds = highestNameIdsDoc.data() ?? {}
    const highestNameId = highestNameIds[item.type] ?? 0
    if (+newId > highestNameId) {
      getFirestore().collection('meta').doc('itemNameIds').set({
        ...highestNameIds,
        [item.type]: +newId,
      })
    }
  }
}
