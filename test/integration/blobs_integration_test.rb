require 'test_helper'

class BlobsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    sign_in users(:user_one)
  end
  test "POST /v1/blobs creates a new data blob with valid data" do
    post "/v1/blobs", params: { id: "test_id", data: "SGVsbG8gV29ybGQh" }
    assert_equal '/v1/blobs', path
    assert_response :created
  end
  test "POST /v1/blobs fails to create a new data blob due to unvalid data" do
    post "/v1/blobs", params: { id: "test_id", data: 526 }
    assert_equal '/v1/blobs', path
    assert_response :bad_request
  end
end