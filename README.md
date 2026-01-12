# op-stack-deploy

Docker 部署配置目录，用于一键构建和部署 op-stack 全栈应用。

## 目录结构

```
op-stack/                          # 项目根目录
├── op-stack-deploy/               # 部署配置目录 (当前目录)
│   ├── README.md                  # 本文件
│   ├── docker-compose.yml         # Docker Compose 编排文件
│   ├── build.sh                   # 一键构建脚本
│   ├── .env.example               # 环境变量模板
│   └── docker/
│       └── mysql/
│           └── init/              # 数据库初始化脚本
│               ├── 00-create-databases.sql
│               └── 01-init-auth.sql
│
├── op-stack-web/                  # 前端项目 (React + Vite)
│   ├── src/
│   ├── dist/                      # 构建产物
│   ├── package.json
│   └── Dockerfile
│
├── op-stack-gateway/              # API 网关 (Spring Cloud Gateway)
│   ├── bootstrap/
│   │   └── target/*.jar           # 构建产物
│   ├── pom.xml
│   └── Dockerfile
│
├── op-stack-service/              # 核心业务服务 (Spring Boot)
│   ├── bootstrap/
│   │   ├── target/*.jar           # 构建产物
│   │   └── src/main/resources/
│   │       └── db/migration/      # Flyway 数据库迁移脚本
│   ├── pom.xml
│   └── Dockerfile
│
├── op-stack-auth/                 # 认证服务 (Spring Boot)
│   ├── bootstrap/
│   │   └── target/*.jar           # 构建产物
│   ├── pom.xml
│   └── Dockerfile
│
├── op-stack-executor/             # AI Agent 执行器 (Python + Flask)
│   ├── src/
│   ├── requirements.txt
│   └── Dockerfile
│
└── op-stack-tools/                # 运维工具服务 (Python + FastAPI)
    ├── src/
    ├── pyproject.toml
    └── Dockerfile
```

## 服务架构

```
                                ┌─────────────┐
                                │   op-web    │
                                │   (3000)    │
                                └──────┬──────┘
                                       │
                                       ▼
                                ┌─────────────┐
                                │  gateway    │
                                │   (8080)    │
                                └──────┬──────┘
                      ┌────────────────┼────────────────┐
                      │                │                │
                      ▼                ▼                ▼
               ┌───────────┐    ┌───────────┐    ┌───────────┐
               │  service  │    │ executor  │    │   tools   │
               │  (8081)   │    │  (8082)   │    │  (8083)   │
               └─────┬─────┘    └───────────┘    └───────────┘
                     │                │
                     │                ▼
                     │         ┌───────────┐
                     │         │   auth    │
                     │         │  (8084)   │
                     │         └─────┬─────┘
                     │               │
                     └───────┬───────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
       ┌───────────┐                 ┌───────────┐
       │   MySQL   │                 │   Redis   │
       │  (3306)   │                 │  (6379)   │
       └───────────┘                 └───────────┘
```

## 服务说明

| 服务 | 端口 | 技术栈 | 说明 |
|------|------|--------|------|
| web | 3000 | React 18 + Vite | 前端应用 |
| gateway | 8080 | Spring Cloud Gateway | API 网关，路由转发 |
| service | 8081 | Spring Boot 3 | 核心业务服务 |
| executor | 8082 | Python + Flask | AI Agent 执行器 |
| tools | 8083 | Python + FastAPI | 运维工具服务 |
| auth | 8084 | Spring Boot 3 | 认证授权服务 |
| mysql | 3306 | MySQL 8.0 | 关系型数据库 |
| redis | 6379 | Redis 7 | 缓存和消息队列 |

## 快速开始

### 前置要求

- Java 21
- Maven 3.9+
- Node.js 20+
- Docker & Docker Compose

### 一键构建部署

```bash
# 1. 进入部署目录
cd op-stack-deploy

# 2. 配置环境变量 (可选)
cp .env.example .env
vim .env

# 3. 一键构建
./build.sh

# 4. 启动服务
docker-compose up -d

# 5. 查看状态
docker-compose ps

# 6. 访问应用
open http://localhost:3000
```

### 手动分步构建

```bash
# Step 1: 打包 Java 后端
cd ../op-stack-service && mvn clean package -DskipTests
cd ../op-stack-auth && mvn clean package -DskipTests
cd ../op-stack-gateway && mvn clean package -DskipTests

# Step 2: 打包前端
cd ../op-stack-web
npm install
npm run build

# Step 3: 构建 Docker 镜像
cd ../op-stack-deploy
docker-compose build

# Step 4: 启动
docker-compose up -d
```

## 常用命令

```bash
# 在 op-stack-deploy 目录下执行

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f [service-name]

# 重启服务
docker-compose restart [service-name]

# 停止服务
docker-compose down

# 停止并清理数据
docker-compose down -v

# 重新构建单个服务
docker-compose build [service-name]
docker-compose up -d [service-name]
```

## 环境变量

详见 `.env.example` 文件。主要配置：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| MYSQL_ROOT_PASSWORD | root123 | MySQL root 密码 |
| JWT_SECRET | ... | JWT 签名密钥 |
| AWS_ACCESS_KEY_ID | - | AWS Access Key (AI 功能) |
| AWS_SECRET_ACCESS_KEY | - | AWS Secret Key (AI 功能) |
| VITE_API_BASE_URL | http://localhost:8080 | 前端 API 地址 |

## 默认账户

- 用户名: `admin`
- 密码: `admin123`

## 数据库

系统自动创建以下数据库：

| 数据库 | 服务 | 说明 |
|--------|------|------|
| op_stack_service | service | 核心业务数据，Flyway 自动迁移 |
| op_stack_auth | auth | 用户认证数据 |
| op_stack_executor | executor | AI 执行器数据，SQLAlchemy 管理 |
| op_stack_tools | tools | 运维工具数据 |

## 故障排除

### 端口冲突

```bash
lsof -i :3000 -i :8080 -i :8081 -i :8082 -i :8083 -i :8084 -i :3306 -i :6379
```

### 查看服务日志

```bash
docker-compose logs -f service
docker-compose logs -f executor
```

### 重置数据库

```bash
docker-compose down -v
docker-compose up -d
```
