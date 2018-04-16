## README

### 1. INFO

**Gateway Service**

The `Gateway` service is a _public facing service_. 
HTTP requests hitting this service are transformed into [NSQ](https://github.com/nsqio/nsq) messages or forwarded in HTTP to specific services.  
Registering services on the gateway and adding new endpoints to it should be **easy**.

#### Public Endpoints

`PATCH /drivers/:id`

**Payload**

```
{
  "latitude": 48.8566,
  "longitude": 2.3522
}
```

**Role:**

In a typical evening 5000 drivers send their coordinates every 5 seconds to this endpoint.

**Behaviour**

Coordinates received on this endpoint are converted to [NSQ](https://github.com/nsqio/nsq) messages listened by the `Driver Location` service.

---

`GET /drivers/:id`

**Response**

```
{
  "id": 42,
  "zombie": true
}
```

**Role:**

The users request this endpoint to know if a driver is a zombie.
A zombie is a driver that has not moved more than 500 meters in the last 5 minutes.

**Behaviour**

This endpoint forward the HTTP request to the `Zombie Driver` service.

**Driver Location Service**


The `Driver Location` service is a microservice that consumes drivers location messages published by the `Gateway` service and stores them in a Redis database.
It also provides an internal endpoint that allow other services to retrieve the drivers data.

#### Internal Endpoint

`GET /drivers/:id/coordinates?minutes=5`

**Response**

```
[
  {
    "latitude": 42,
    "longitude": 2.3,
    "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
  },
  {
    "latitude": 42.1,
    "longitude": 2.32,
    "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
  }
}
```

**Behaviour**

Returns for a given driver all his coordinates from the last 5 minutes (given `minutes=5`).


**Zombie Driver Service**


The `Zombie Driver` service is a microservice that determines if a driver is a zombie or not.

#### Internal Endpoint

`GET /drivers/:id`

**Response**

```
{
  "id": 42,
  "zombie": true
}
```

**Role:**

This endpoint is called by the `Gateway Service`.

**Predicate**

> driver has not moved from more than 500 meters in the last 5 minutes.

**Behaviour**

Returns for a given driver his zombie state.

### 2. Install NSQ
You have to install [NSQ](https://github.com/nsqio/nsq).

After installing it the service must be opened:

Open a shell and type:
```$ nsqlookupd```


Open another shell and type:
```$ nsqd --lookupd-tcp-address=127.0.0.1:4160```

And another shell and type:
```$ nsqadmin --lookupd-http-address=127.0.0.1:4161```

You can view stats about the service by going to: http://127.0.0.1:4171/

### 3. Redis

Install [Redis](https://redis.io/topics/quickstart)

Start redis in a shell: ```$ redis-server```

### 4. Apps

**Setup**

Clone the repo to a path of your choosing

After the repo has been set up you need to go into each folder and run bundle install(assuming you are in the repo):
```cd driver_location/ && bundle install && cd ..```  

```cd gateway_api/ && bundle install && cd ..```  

```cd zombie_driver && bundle install && cd ..```  

**Start Sidekiq**

Go to the driver_location folder and run ```sidekiq start```

**Start Apps**

In another terminal go in the gateway_api folder and run: ```rails s -p 3000```
In another terminal go in the driver_location folder and run: ```rails s -p 3001```
In another terminal go in the zombie_driver folder and run: ```rails s -p 3002```

### 5. Inner workings

The gateway api receives requests at ```PATCH /drivers/:id``` in the form:

```
{
  "latitude": 48.8566,
  "longitude": 2.3522
}
```
It transforms this data in messages and queues them in the NSQ service.

When opening driver_location app a sidekiq also starts that will loop infinitely and check for new messages. When a new message is found it reads it and stores it in redis.

Gateway_api can also respond to ```GET /drivers/:id``` a request that it forwards to zombie_driver. The zombie_driver service requests data from the driver_location service and based on that data says if the driver is a zombie or not. The answer is giver to the gateway_api which in turn displays it.



### 6. Improvements that can be made:

1. Use faster frameworks for gateway(like sinatra/or another language like GoLang)
2. Use sorted sets with timestamp as the score for rails cache (ZRANGEBYSCORE driver_id n_seconds_ago_epoch +inf command / ZADD driver_id timestamp_epoch lat:lon:timesamp)
3. Don't make a new connection to the producer for every request might overwhelm it.
4. Store the time as epoch time so I don't have to parse it.
5. Add emails when errors occur.

