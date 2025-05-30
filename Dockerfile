# Stage 1: Build the Vue.js application
# 使用 Node.js 20 的 Alpine 版本作为构建环境，减小镜像大小
FROM node:20-alpine AS builder

WORKDIR /app

# 复制 package.json 和 package-lock.json，并安装依赖
# 这样可以利用 Docker 缓存，如果依赖不变，则跳过 npm install
COPY package.json package-lock.json ./
RUN npm install --frozen-lockfile

# 复制前端代码
COPY . .

# 执行 Vue 项目的构建命令
# Vite/Vue CLI 默认构建命令是 'npm run build'，输出到 'dist' 目录
RUN npm run build

# Stage 2: Serve the built static files with Nginx
# 使用 Nginx 的 Alpine 版本作为最终的生产环境服务器
FROM nginx:alpine

# 从 builder 阶段复制构建好的静态文件到 Nginx 的默认静态文件目录
# Vue 项目默认构建输出目录是 'dist'
COPY --from=builder /app/dist /usr/share/nginx/html

# 移除 Nginx 默认配置文件，替换为我们自己的配置
RUN rm /etc/nginx/conf.d/default.conf

# 复制自定义的 Nginx 配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 Nginx 监听的端口 (容器内部的 80 端口)
EXPOSE 80

# 启动 Nginx 服务
CMD ["nginx", "-g", "daemon off;"]