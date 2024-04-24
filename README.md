# pgvector集群部署
结合 [postgresql-repmgr](https://hub.docker.com/r/bitnami/postgresql-repmgr)和[pgvector](https://hub.docker.com/r/pgvector/pgvector) 构建支持向量数据的postgresql集群.

## 使用
本项目只提供基于 `postgresql 16` 和 `pgvector 0.6.2` 的docker镜像.
```shell
docker pull barrychen714/pgvector-repmgr:16.2-0.6.2
```

## 自己构建
如果你想要构建其他版本的pgvector-repmgr, 可以参考以下方案.

### 方案1
启动postgresql-repmgr容器, 进入容器, 安装postgresql-16-pgvector, 得到vector相关的文件. 复制到宿主机.
然后在build时, 把文件复制到容器中.
见Dockerfile

1. 启动postgresql-repmgr容器
`docker stack deploy -c docker-compose.yaml postgresql-repmgr`

docker-compose.yaml文件如下所示
```
version: '3.9'
services:
  pg-0:
    image: docker.io/bitnami/postgresql-repmgr:16
    ports:
      - 5432
    volumes:
      - pg_0_data:/bitnami/postgresql
    environment:
      - POSTGRESQL_POSTGRES_PASSWORD=adminpassword
      - POSTGRESQL_USERNAME=customuser
      - POSTGRESQL_PASSWORD=custompassword
      - POSTGRESQL_DATABASE=customdatabase
      - REPMGR_PASSWORD=repmgrpassword
      - REPMGR_PRIMARY_HOST=pg-0
      - REPMGR_PRIMARY_PORT=5432
      - REPMGR_PARTNER_NODES=pg-0
      - REPMGR_NODE_NAME=pg-0
      - REPMGR_NODE_NETWORK_NAME=pg-0
      - REPMGR_PORT_NUMBER=5432
volumes:
  pg_0_data:
    driver: local
```

2. 进入刚刚启动的容器,并安装`postgresql-16-pgvector`
```shell
# 进入容器
docker exec -it -u root [container_id] /bin/sh
# 如果在国内, 可以设置镜像源.
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# 安装vector
apt-get update && apt install -y postgresql-common
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
apt-get install -y postgresql-16-pgvector

exit
```

3. 把上一步安装的vector插件文件复制到宿主机, 注意你当前安装的vector的版本.
```shell
docker cp [container_id]:/usr/lib/postgresql/16/lib/vector.so postgresql/16/lib
docker cp [container_id]:/usr/share/postgresql/16/extension/vector.control postgresql/16/share/extension/vector.control
docker cp [container_id]:/usr/share/postgresql/16/extension/vector--0.6.2.sql postgresql/16/share/extension/vector--0.6.2.sql
```

4. 构建镜像
```shell
docker build -t pgvector-repmgr:latest .
```

### 方案2
把方案1的流程置于Dockerfile中.
见Dockerfile2