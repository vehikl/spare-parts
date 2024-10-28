import {UserRecord} from 'firebase-admin/lib/auth/user-record'
import {associateUserWithExistingItems} from './associateUserWithExistingItems'

describe('associateItemWithExistingUsers', () => {
  it('associates item with existing users', () => {
    // create user
    const user = new UserRecord()
    // seed items with user email

    // call function with item and user
    associateUserWithExistingItems(user)

    // assert item's borrower uid is same as user's
  })
})
