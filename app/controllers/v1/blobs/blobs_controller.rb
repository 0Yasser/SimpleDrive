class V1::Blobs::BlobsController < ApplicationController
  # def index
  #   # render json: 'UserSerializer.new(current_user).serializable_hash[:data][:attributes]', status: :ok
  # BlobSerializer.new(request.body.read).serializable_hash[:data][:attributes]
  # end
  def index
    id_or_path = params[:id_or_path]
    puts id_or_path
    blob_md = BlobMetadatum.find_by(blob_id: id_or_path)
    puts blob_md
    if !blob_md
      render json: {status: 404, message: 'There is no stored BLOB with the given ID'}, status: :not_found
      return
    end

    begin
      if blob_md.storage_type == "aws_s3"
        s3 = Aws::S3::Client.new
        stored_blob = s3.get_object(bucket: 'simple-drive-project',
        key: id_or_path)
      end
      resource = {
        id: blob_md.id,
        data: stored_blob['body'].string,
        size: blob_md.size,
        created_at: blob_md.created_at
      }
    rescue => e
      # puts e.message 
      render json: {status: 400, message: "Failed to retrieve object"}, status: :bad_request
      return

    end
    render json: resource, status: :ok
  end

  def create
    # body = JSON.parse(request.body.read)
    id, data = params['blob']['id'], params['blob']['data']
    begin
      decoded_str = Base64.urlsafe_decode64(data)
      decoded_str_len = decoded_str.bytesize
      ActiveRecord::Base.transaction do
        new_blob_md = BlobMetadatum.create(blob_id: id, size: decoded_str_len, storage_type: "aws_s3", poster_id:"")
        s3 = Aws::S3::Client.new
        s3.put_object(
          bucket: 'simple-drive-project',
          key: id,
          body: data
        )
      end
    rescue => e
      # puts e
      render json: {status: 400, message: "Failed to store at AWS S3"}, status: :bad_request
      return
    end

    render json: decoded_str, status: :created
  end

  def show
  end

  def destroy
  end
end
