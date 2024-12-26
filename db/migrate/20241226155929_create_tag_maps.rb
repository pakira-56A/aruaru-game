class CreateTagMaps < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_maps do |t|

      # references型使って、予想外のidが入らないようにする
      t.references :post, foreign_key: true
      t.references :tag, foreign_key: true

      t.timestamps
    end
  end
end
