require "test_helper"

class BlobTest < ActiveSupport::TestCase
  test "create a new data blob with valid attributes" do
    blob = Blob.new(id: "test_id", data: "SGVsbG8gV29ybGQh")
    assert blob.save
  end

  test "generate the relevant timestamps upon data blob creation" do
    blob = Blob.create(id: "test_id", data: "SGVsbG8gV29ybGQh")
    assert_not_nil blob.created_at
    assert_not_nil blob.updated_at
  end

end
