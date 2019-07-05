#### readme

the server is used to execute the linux bash and it can Print results can be displayed in real time

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
