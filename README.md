# Data Demo API

Mini API for Data Pipeline Demo.

## Features

- Upload file
- Process file (ZIP compression)
- Download processed file

## Run

mvn clean package
java -jar target/data-demo-api-1.0.0.jar

## Endpoints

POST /api/files/upload
POST /api/files/process/{id}
GET  /api/files/download/{id}
