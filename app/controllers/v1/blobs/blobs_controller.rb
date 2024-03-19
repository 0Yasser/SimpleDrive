class V1::Blobs::BlobsController < ApplicationController
  before_action :authenticate_user!
  def index
    id_or_path = params[:id_or_path]
    blob_md = BlobMetadatum.find_by(blob_id: id_or_path)
    if !blob_md
      render json: {status: 404, message: 'There is no stored BLOB with the given ID'}, status: :not_found
      return
    end

    begin
      if blob_md['storage_type'] == "aws_s3"
        s3 = Aws::S3::Client.new
        stored_blob_data = s3.get_object(bucket: 'simple-drive-project',
        key: id_or_path)['body'].string
      elsif blob_md['storage_type'] == "db"
        stored_blob_data = Blob.find_by(:blob_id=>id_or_path)['data']
      elsif blob_md['storage_type'] == "local"
        file_path = Rails.root.join('public', 'uploads', "#{id_or_path}.txt")
        File.open(file_path, 'r') do |f|
          stored_blob_data = f.read
        end
      # else
      end
      resource = {
        id: blob_md.id,
        data: stored_blob_data,
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
    id, data, type = params['id'], params['data'], params['type'] ? params['type'] : 'aws_s3'
    if BlobMetadatum.exists?(:blob_id=>id)
      render json: {status: 400, message: "There already a data BLOB with the given ID"}, status: :bad_request
      return
    end
    begin
      decoded_str = Base64.urlsafe_decode64(data)
      decoded_str_len = decoded_str.bytesize
      ActiveRecord::Base.transaction do
        new_blob_md = BlobMetadatum.create(blob_id: id, size: decoded_str_len, storage_type: type , poster_id:"")
        if type == 'aws_s3'
          s3 = Aws::S3::Client.new
          s3.put_object(
            bucket: 'simple-drive-project',
            key: id,
            body: data
          )
        elsif type == 'db'
          new_blob = Blob.new(data:data)
          new_blob.blob_id = id
          new_blob.save()
        elsif type == 'local'
          directory = Rails.root.join('public', 'uploads')
          FileUtils.mkdir_p(directory) unless File.directory?(directory)
          file_path = File.join(directory, "#{id}.txt")
          File.open(file_path, 'w') do |f|
            f.write(data)
          end
        else
          ActiveRecord::Base.connection.rollback
        end
      end
    rescue => e
      # puts e
      render json: {status: 400, message: "Failed to store at #{type}"}, status: :bad_request
      return
    end

    render json: {encoded_string: decoded_str, message: "Saved Successfully"}, status: :created
  end

  def show
  end

  def destroy
  end
end
