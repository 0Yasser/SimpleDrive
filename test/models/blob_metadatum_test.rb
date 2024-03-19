require "test_helper"

class BlobMetadatumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "create a new data blob metadata object with valid attributes" do
    blob = BlobMetadatum.new(blob_id: "test_id", size: 13, storage_type: 'db')
    assert blob.save # Assuming encoded data size is 13 bytes
  end
end
