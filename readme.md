#### readme

the server is used to execute the linux bash and it can Print results can be displayed in real time

If the service is running in Ubuntu, remember to turn off the firewall on the response port. Also, when executing commands with SSH, you need to execute `nohup node /root/project/server/app.js &`

- `npm i` to configure the environment

- `npm start` to start the server

- `curl http://localhost:port` can test case

file:

- app.js  main file of the server

- config.json  the key is the id of file, value is the bash filename

- utility.js some tools we can use

- scripts bash shell script
  
    - hello-world  test script
    
    - mongodump  mongo data Backup
      
        ```
        DB_HOST='' # mongo host
        DB_NAME='' # mongo database
        
        OUT_DIR='' # Temporary catalogue
        TAR_DIR='' # Backup storage path
        
        DB_USER='' # mongo username
        DB_PASS='' # mongo user password
        DAYS=7 # Keep the file for 7 days 
        ```

- docker_container 
  
    - create docker container and Scheduled backup mongo(00:00 on every Friday)
    
    - do like this
    ```
        docker build -t cron-in-docker . # create docker images and contain
        docker run --rm -it cron-in-docker # Explicitly run the container to observe the results
    ```

- ./scripts/kill_mongo_timeout.js
  
  - kill some timeout mongoshell 
      - `secs_runningsecs_running` time about running
      - `if`  weather ip is equal to xx or not
  