class AddOgpToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :ogp, :string
  end
end
