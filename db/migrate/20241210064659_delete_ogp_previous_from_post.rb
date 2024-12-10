class DeleteOgpPreviousFromPost < ActiveRecord::Migration[7.1]
  def up
    remove_column :posts, :previous_user_name
    remove_column :posts, :previous_title
  end

  def down
    add_column :posts, :previous_user_name, :string
    add_column :posts, :previous_title, :string
  end
end
