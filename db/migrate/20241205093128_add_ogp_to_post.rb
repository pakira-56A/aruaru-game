class AddOgpToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :ogp, :string
    add_column :posts, :previous_user_name, :string
    add_column :posts, :previous_title, :string
  end
end
