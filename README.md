# progimage

<!-- From the task -->

## Context

You are a senior member of a team that has has been tasked with developing a programmatic image storage and processing service called ProgImage.com.

Unlike other image storage services that have a web front-end and target end-users, ProgImage is designed as a specialised image storage and processing engine to be used by other applications, and will (only) provide high-performance programmatic access via its API.

Apart from bulk image storage and retrieval, ProgImage provides a number of image processing and transformation capabilities such as compression, rotation, a variety of filters, thumbnail creation, and masking.

These capabilities are all delivered as a set of high-performance web-services that can operate on images provided as data in a request, operate on a remote image via a URL, or on images that are already in the repository. All of the processing features should be able to operate in bulk, and at significant scale.

## Challenge

### Required
Build a simple microservice that can receive an uploaded image and return a unique identifier for the uploaded image that can be used subsequently to retrieve the image.

**Assumptions:**

*   "receive an uploaded image" translates to "receive a binary file of a image in a recognised format ("JPEG", "JPG", "PNG", "SVG") carrying the correct extension"
*   "unique identifier" is unique to the uploaded image instance
*   "simple microservice" is indicative of single purpose service built to the smallest deliverable quality
*   "upload is made using content-type:image/x"
*   "an uploaded image" means a single image
*   "and return a unique identifier" is non-specific on return type therefore JSON will be used
*   "can be used subsequently to retrieve the image" is non-specific, therefore a url will be returned

Extend the microservice so that different image formats can be returned by using a different image file type as an extension on the image request URL.

**Assumptions:**

*   "returned by using a different image file type" translates to "convert to a recognised  file of a image in a recognised format ("JPEG", "JPG", "PNG", "SVG")"
*   "as an extension on the image request" is assumed to mean that the file would be downloaded using a format of <host><path><filename><ext> where changing the <ext> would enable the downloading of a different format"
*   "assumed no requirements on whether these images are persisted"

Write a series of automated tests that test the image upload, download and file format conversion capabilities.

**Assumptions:**

*   It is assumed that automated tests can be written in any language

### Stretch
Write a series of microservices for each type of image transformation. Coordinate the various services using a runtime virtualisation or containerisation technology of your choice.

**Assumptions:**

*   It is assumed this is two different requirements. Hosting in a runtime environment and separation of the image format transformations into separate services.
*   There are two design approaches, the first is on-demand transformation, and the second is preprocessing. The latter is only generally applicable if the demand is known and the type of transformation is expensive.
*   In this scenario as the image format transformations are so simple, no tangible benefit can be driven from their separation at this point. If this was a desire, then the following would be sensible: swapping from a HTTP rest call to a gRPC call, and separation of the logic into layers where the first layer was a router based on the ask. The time to process the image would increase, therefore this would only be a desirable architectural choice if the intend was to expand to image to other transformations such as colour, resizing, reshaping, merging, etc.

Design a language-specific API shim (in the language of your choice) for ProgImage as a reusable library (eg Ruby Gem, Node Package, etc). The library should provide a clean and simple programmatic interface that would allow a client back-end application to talk to the ProgImage service. The library should be idiomatic for the target language.

## Questions
1.  What language platform did you select to implement the microservice? Why?

Answer: Python, as I was provided a choice of Python, Java or Swift. Preference would have been for GoLang

2.  How did you store the uploaded images?

Answer: Shared disk. Rational? Fast, scalable & cheap. In a production environment this would be backed by the large cloud volume.

3.  What would you do differently to your implementation if you had more time?

Answer:
*   performance testing through the addition of instrumentation to tune the upload & download calls
*   construction of background services to allow larger files to be converted in an asynchronous manner
*   implement the background service to clean up the image based on its ttl
*   build shims for bash & go
*   modified the svg conversion to trace rather than replicate. Currently it creates converts each pixel into a 1x1 coloured square which creates a huge amount of xml.

4.  How would coordinate your development environment to handle the build and test process?

Answer: A white board, it always starts with a white board. We would detail the requirements and the team would design out the architecture. Once the team was content on the approach, it would be broken in stories, and pairs would pick up the stories. A story is only complete once you can programmatically prove it is. Pairs would be encouraged to use TDD.

5.  What technologies would you use to ease the task of deploying the microservices to a production runtime environment?

Answer: An orchestration tool that is good enough for the expectations of our production users. If the service is expected to be up to 5x9s then it would need to be treated that way, most likely with canary releases. If however, we were looking at 4x9s, red/black would be acceptable, provided we had fast rollback capabilities. Managing a production environment is more about process than it is tech. If you can use dev friendly technologies such as cloudrun and still cause an outage. However, to answer the question, I favour the following stack at the moment:

*   Kubernetes (gke)
*   Istio
*   FluxCD
*   Concourse
*   Helm

6.  What testing did (or would) you do, and why?

Answer: I am strong believer in TDD, and that favours feature/outcome based testing vs unit testing. I would also take the ability to regression test over the ability to be happy that my unit runs as designed. Unit testing has a place, especially in complex methods, or common modules, however the majority of code that is produced by teams is far from novel. If there was more time, I would script performance & reliability tests.

Testing performed:
*   feature

Testing not performed:
*   unit testing
*   performance
*   reliability
*   system
*   load

## Design Decisions

### HTTP rather than gPRC
gRPC offers plenty of useful features, such as sending messaging mid upload to allow progress to be tracked, however transferring files over gRPC is an order of magnitude slower (x2) than [HTTP][1]. Thus, we stayed away from it for this use case.

### Use Falcon as the API framework
As the requirements were simple, the decision to use a fast lightweight framework to reduce the amount of coding required within Python to make this api work. Out of the frameworks, Falcon is the fastest.

### Separate POST /images & GET /images
As both APIs have different requirements on features, scalability, uptime, & maintainability separation can allow for each api to be tailored for its requirements.    

### Block incorrect files extensions
Although it would be easy to just allow the upload of any file, it has been implemented to only allow images to be uploaded. It does this first checking the content-type header & then actually testing the file for characteristics of an image type. The latter is unlikely to be 100%, however it should limit the number of files uploaded that are consuming space and outside the scope of this service.

### Save & clean duplicates
Two design patterns were considered:
a) Determine the sha of the file during the upload process, check if it exists already then only save if it doesn't exist.
b) Treat every upload as unique, clean up the file storage in a batch job.

The decision was to implement (b) due to the performance impacts & complexity of race conditions in (a).

### Column:Value store implemented
To allow a clean up of duplicate files then a db implemented as the registry mapping of file name to real filters

### 5 records per file vs one in redis cache
Optimised for read rather than writing, either would be pretty quick. A key advantage of storing 5 records, one for each downloadable version, within the redis cache, is that is avoids a race condition on update.

### JIT file conversion
Slowing down the GET of a file if it does not exist, however this penalty was taken over storage of files not required.

### File saving of new formats post creation
Once created, converted images are persisted to reduce the time for future calls.

[1]: https://ops.tips/blog/sending-files-via-grpc/
