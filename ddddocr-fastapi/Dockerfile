# 使用官方 Python 运行时作为父镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 将当前目录内容复制到容器的 /app 中
## RUN git clone --quiet https://github.com/sml2h3/ddddocr-fastapi.git /app 
COPY ddddocr-fastapi/. /

# 安装项目依赖
RUN pip install --no-cache-dir -r /requirements.txt

# 暴露端口 8000
EXPOSE 8000

# 运行应用
CMD python main.py
