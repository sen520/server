设置登录密码需要配置keyfile， 

```
version: '2'
services:
  db0:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db0:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27018:27017"
    command: mongod --replSet rs0 --auth --keyFile /data/common/mongodb-keyfile
    links:
      - db1
      - db2
      
  db1:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db1:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27019:27017"
    command: mongod --replSet rs0 --auth --keyFile /data/common/mongodb-keyfile
    
  db2:
    image: mongo:4.0
    restart: always 
    mem_limit: 4G
    volumes:
      - /workspace/mongo-alpha/db2:/data/db
      - /workspace/mongo-alpha/common:/data/common
    environment:
      TZ: Asia/Shanghai
    ports:
      - "27020:27017"
    command: mongod --replSet rs0 --auth --keyFile /data/common/mongodb-keyfile
    

```

配置过登录密码后，通过`openssl rand -base64 725  > /home/mongodb.key`生成`mongodb-keyfile`

`mongodb-keyfile`需要设置权限，权限太低会报`permission denied `，权限太高会报`permission to open`，`chmod 600 keyfile`或者`chown 999:999 keyfile`，并且，每个主机都要相同

