#### readme

这个服务用于执行linux脚本信息，同时实时在控制台显示结果，该服务可以动态加载新添加的脚本信息，但此脚本信息需要在config.json注册

the server is used to execute the linux bash and it can Print results can be displayed in real time

这个服务如果运行在ubuntu等服务器上，记得要打开相应端口号的防火墙，并且，如果通过ssh连接、执行，需要运行下面命令来保证server在断开ssh时不被杀掉`nohup node /root/project/server/app.js &`
或者 `setsid node /root/project/server/app.js` 开通防火墙响应端口可以[点此](https://blog.csdn.net/hqbootstrap1/article/details/94123307)查看

If the service is running in Ubuntu, remember to turn off the firewall on the response port. Also, when executing commands with SSH, you need to execute `nohup node /root/project/server/app.js &`
or `setsid node /root/project/server/app.js` You can [click here](https://blog.csdn.net/hqbootstrap1/article/details/94123307) to activate the firewall response port. 

**注意**：在`app.js`的47行`spawn('sh', [./scripts/${filePath}])`，你应该修改为绝对路径

**Be careful**: You should change the path to absolute path in `app.js` line 47 `spawn('sh', [./scripts/${filePath}])`

- `npm i` to configure the environment  安装环境

- `npm start` to start the server  启动服务

- `curl http://localhost:port` can test case  测试服务

file:

- app.js  main file of the server

- config.json  the key is the id of file, value is the bash filename  键为脚本id，值为脚本名称

- utility.js some tools we can use

- scripts bash shell script
  
    - hello-world  test script  测试
    
    - mongodump  mongo data Backup   Mongodb数据库备份
      
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
