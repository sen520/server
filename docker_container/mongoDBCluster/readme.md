# **基于 Docker 的 MongoDB 主从集群**

## 概述

- 前序–聊聊数据库升级方案
- 一主一从
- 一主两从
- 一主一从一仲裁

本来是想用 MongoDB 的 Docker 最新镜像的，但是 最新镜像默认绑定了 localhost 才能连接数据库，当然，我们也可以进行修改。那我这边为了方便，就直接使用 mongo 3.4 ，因为 3.4 的版本没有绑定 localhost 省去一部分麻烦。

## 前序–聊聊数据库升级方案

在学习集群之前，我们来聊聊数据库的升级方案，我个人认为有如下一些阶段，如果我的认知有错误，也烦请读者朋友指出。

```
阶段一
描述：开发初期，应用程序与数据库在同一台服务器
缺点：
 - 应用程序与数据库争夺资源
 - 数据库挂掉，应用程序也无法提供服务
 - 无法提供数据容灾备份
 - 读写在同一个节点，压力大
 - 吞吐量小，提供服务能力有限
 - 无故障恢复功能
阶段二
描述：数据库独立到一台服务器，与应用程序分离
缺点：
 - 数据库挂掉，应用程序也无法提供服务
 - 无法提供数据容灾备份
 - 读写在同一个节点，压力大
 - 吞吐量小，提供服务能力有限
 - 无故障恢复功能
阶段三
描述：数据库有主从结构，一台主要，一台副本
缺点：
 - 数据库挂掉，应用程序也无法提供服务
 - 读写在同一个节点，压力大
 - 吞吐量小，提供服务能力有限
 - 无故障恢复功能
阶段四
描述：一主两（多）从，读写分离
缺点：
 - 吞吐量小，提供服务能力有限
 - 数据库节点多，经济成本相对增大
阶段五
描述：分片，横向扩展
缺点：
 - 数据库节点多，经济成本相对增大
```

## 一主一从

```
version: '2'
services:
  master:
    image: mongo:3.4
    volumes:
      - /data/mongodbml/master:/data/db
    command: mongod --dbpath /data/db --master
  slaver:
    image: mongo:3.4
    volumes:
      - /data/mongodbml/slaver:/data/db
    command: mongod --dbpath /data/db --slave --source master:27017
    links:
      - master
```

不用新建相应文件目录，直接运行 yml 文件即可。
在运行 yml 文件之后，执行以下初始化操作：
进入 master 的 mongo 命令行：

```
docker-compose exec master mongo
```

插入一条数据：

```
use test
db.test.insert({msg: "this message is from master", ts: new Date()})
```

进入 slaver 的 mongo 命令行：

```
docker-compose exec slaver mongo
```

查看副本集信息：

```
rs.slaveOk()
use test
db.test.find()
```

rs.slaveOk() 的功能

```
db.getMongo().setSlaveOk()
This allows the current connection to allow read operations to run on secondary members. See the readPref() method for more fine-grained control over read preference in the mongo shell.
```

![这里写图片描述](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAANSURBVBhXYzh8+PB/AAffA0nNPuCLAAAAAElFTkSuQmCC)
在 slave 中，查询到了 master 中插入的信息
尝试在 slave 中，插入信息：

```
db.test.insert({msg: 'this is from slaver', ts: new Date()})
```

插入失败，显示报错信息。

**优缺点：** master-slave 结构，当 master 挂了，slave 不会被选举为 master，所以这种结构只起到了备份数据的作用

## 一主两从

```
version: '2'
services:
  rs1:
    image: mongo:3.4
    volumes:
      - /data/mongodbtest/replset/rs1:/data/db
    command: mongod --dbpath /data/db --replSet myset
  rs2:
    image: mongo:3.4
    volumes:
      - /data/mongodbtest/replset/rs2:/data/db
    command: mongod --dbpath /data/db --replSet myset
  rs3:
    image: mongo:3.4
    volumes:
      - /data/mongodbtest/replset/rs3:/data/db
    command: mongod --dbpath /data/db --replSet myset
```

不用新建相应文件目录，直接运行 yml 文件即可。
在运行 yml 文件之后，执行以下初始化操作：

```
docker-compose exec rs1 mongo
```

初始化各个节点：

```
rs.initiate()
rs.add('rs2:27017')
rs.add('rs3:27017')
```

查看配置与副本级状态

```
rs.conf() 
rs.status() 
```

插入信息到主节点：

```
docker-compose exec rs1 mongo
use test
db.test.insert({msg: 'this is from primary', ts: new Date()})
```

在副本集中检测信息是否同步：

```
docker-compose exec rs2 mongo
rs.slaveOk()
use test
db.test.find()
docker-compose exec rs3 mongo
rs.slaveOk() //副本集默认仅primary可读写
use test
db.test.find()
```

故障测试：

```
docker-compose stop rs1
```

分别查看其它节点的信息：注意进入 mongo 命令行后的主从标识符

```
docker-compose exec rs2 mongo
docker-compose exec rs3 mongo
```

**优缺点：**

1. 可进行读写分离
2. 具备故障转移能力

## 一主一从一仲裁

```
version: '2'
services:
  master:
    image: mongo:3.4
    volumes:
      - /data/mongodb3node/replset/rs1:/data/db
    command: mongod --dbpath /data/db --replSet newset --oplogSize 128
  slave:
    image: mongo:3.4
    volumes:
      - /data/mongodb3node/replset/rs2:/data/db
    command: mongod --dbpath /data/db --replSet newset --oplogSize 128
  myarbiter:
    image: mongo:3.4
    command: mongod --dbpath /data/db --replSet newset --smallfiles --oplogSize 128
```

不用新建相应文件目录，直接运行 yml 文件即可。
在运行 yml 文件之后，执行以下初始化操作：

```
docker-compose exec rs1 mongo
```

初始化各个节点：

```
rs.initiate()
rs.add('slave:27017')
rs.add('myarbiter:27017',true)//设置为仲裁节点
```

查看配置与副本级状态

```
rs.conf() 
rs.status() 
```

插入信息到主节点：

```
docker-compose exec rs1 mongo
use test
db.test.insert({msg: 'this is from primary', ts: new Date()})
```

在副本集中检测信息是否同步：

```
docker-compose exec rs2 mongo
rs.slaveOk()
use test
db.test.find()
docker-compose exec rs3 mongo
rs.slaveOk() //副本集默认仅primary可读写
use test
db.test.find()
```

故障测试：

```
docker-compose stop master
```

分别查看其它节点的信息：

```
docker-compose exec slave mongo
```

![这里写图片描述](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAANSURBVBhXYzh8+PB/AAffA0nNPuCLAAAAAElFTkSuQmCC)
可以看到最后一行标注为： PRIMARY 故障转移成功

```
docker-compose exec myarbiter mongo
```

![这里写图片描述](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAANSURBVBhXYzh8+PB/AAffA0nNPuCLAAAAAElFTkSuQmCC)
可以看到最后一行标注为： ARBITER

**优缺点：**

1. 具备故障转移能力
2. 仲裁节点起到选举作用，节省部分资源