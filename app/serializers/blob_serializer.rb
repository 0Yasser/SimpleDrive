class BlobSerializer
  include JSONAPI::Serializer
  attributes :id, :data
end
