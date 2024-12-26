class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :tag_name

      t.timestamps
    end
  end
end
