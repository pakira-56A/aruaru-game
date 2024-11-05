class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|

      t.string :title, null: false
      t.string :aruaru_one, null: false
      t.string :aruaru_two, null: false
      t.string :aruaru_three, null: false
      t.string :aruaru_four, null: false
      t.string :aruaru_five, null: false

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
