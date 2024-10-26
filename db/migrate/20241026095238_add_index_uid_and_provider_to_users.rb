class AddIndexUidAndProviderToUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :users, [:uid, :provider], unique: true, name: 'index_users_on_uid_and_provider'
  end
end
