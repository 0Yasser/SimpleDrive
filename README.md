# Simple Drive Project

This Ruby on rails application provides an API to store/retrieve objects from a storage source of choice (AWS S3, SQL databse or in the local file system)


## Getting Started
To get started with the Simple Drive Project, follow these steps:

### Prerequisites
- Ruby (preferably on version 3.2.3)
- Ruby on Rails (preferably on version 7.1.3)
- Bundler gem

### Installation
1. Clone the repository:
`git clone https://github.com/0Yasser/SimpleDrive.git`
2. Install dependencies:
`bundle install`

3. Set up the database:
`rails db:setup`

4. Start the Rails server:
`rails s`



### Configuration
To run the project locally there is some steps required for a AWS S3 bucket configuration, the full guide is available at [Rails official guide on setting up AWS S3](https://edgeguides.rubyonrails.org/active_storage_overview.html#s3-service-amazon-s3-and-s3-compatible-apis)

Generally the steps are:
1. Create a new S3 bucket with the name and region that are defined here in the `storage.yml` file
2. Check on `ACLs enabled` instead of the default on the creation page
3. Remove the check on the block all publick access checkbox on the creation page, preferably just check the last two
4. Now create the bucket
5. Create a new IAM Policy:
  5.1. Specify the policy service to be on s3 service only
  5.2. Specify the policy actions to be: ListBucket, GetObject, PutObject, DeleteObject, PutObjectAcl
  5.3. Specify the policy resources to add the following bucket names: `simple-drive-project` and `simple-drive-project/*` or whatever are the names defined here in the `storage.yml` file
  5.4. Create the IAM policy with a given name
6. Create a new IAM user:
  6.1. In the permissions options choose `attach policies directly` and choose the previously created IAM policy
  6.2. Create the user
7. Check the new IAM user's security credentials and create a new access key
8. Choose application running outside AWS and now create the access key
9. Copy the credentials (Access key & Secret access key) and put them in the rails project's credentials
  9.1. For that, do `EDITOR="code --wait" rails credentials:edit` to open you rails credentials in VSCode
  9.2. Add the following lines then save and close: 
  ```
  aws:
    access_key_id: <your-access-key-id>
    secret_access_key: <your-secret-access-key>
  ```
10. To avois CORS problems copy the following:
```
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "http://127.0.0.1:3000",
      "http://localhost:3000",
    ],
    "ExposeHeaders": [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "MaxAgeSeconds": 3600
  }
]
```
Then go to the permissions tab in the S3 bucket, to the CORS field then edit then paste it here and save

### Usage
The Simple Drive provides the following endpoints:

POST `/v1/auth/signup`: Registers a new user
Request body:
```
{
    "user":{
        "email":"admin@test.com",
        "password":"password123",
        "password_confirmation": "password123"
    }
}
```

POST `/v1/auth/login`: Login with a user email and password and return a JWT Bearer Token in the response Authorization header
Request body:
```
{
    "user":{
        "email":"admin@test.com",
        "password":"password123"
    }
}
```

DELETE `/v1/auth/logout`: Logout the current user

GET `/v1/users/details`: Returns the current user details (the logged in user from the request Authorization header)

POST `/v1/blobs`: Store a blob of data in AWS S3 by default, but can store in a database if provided  `type: "db"` or in the local system if `type: "local"` , the request should have a valid token in the request Authorization header or it will fail with status code 401: Unauthorized
Request Body:
```
{
    "id": "some_id",
    "data": "SGVsbG8gU2ltcGxlIFN0b3JhZ2UgV29ybGQh"
}
```
GET `/v1/blobs/:id`: Retrieve a blob of data by its ID or path , it check the metadata table first to get its metadata and to know where it stored, then checks its storage destination and returns it, the request should have a valid token in the request Authorization header or it will fail with status code 401: Unauthorized

### Authentication
All requests to the service aside from the signup require authentication using Bearer token authentication.

### Testing
The project includes unit tests and integration tests. To run every test, execute the following command: `rails test`
