FROM python:3.10-alpine

WORKDIR /app
EXPOSE 9763/tcp
RUN apk add git gcc
RUN git clone --quiet https://github.com/MeoProject/lx-music-api-server.git /app 

# 指定源, 如果后期源挂了, 更换个源就可以.
RUN pip install --no-cache -r /app/requirements.txt

CMD [ "python", "main.py" ]