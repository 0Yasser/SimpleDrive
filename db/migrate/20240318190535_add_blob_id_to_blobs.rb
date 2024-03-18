class AddBlobIdToBlobs < ActiveRecord::Migration[7.1]
  def change
    add_column :blobs, :blob_id, :string
    add_index :blobs, :blob_id
  end
end
