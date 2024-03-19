class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs do |t|
      t.string :data

      t.timestamps
    end
  end
end
