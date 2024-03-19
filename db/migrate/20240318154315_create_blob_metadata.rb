class CreateBlobMetadata < ActiveRecord::Migration[7.1]
  def change
    create_table :blob_metadata do |t|
      t.string :blob_id
      t.string :size
      t.string :storage_type
      t.string :poster_id

      t.timestamps
    end
  end
end
