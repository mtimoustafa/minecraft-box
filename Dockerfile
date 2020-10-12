# Install Python
FROM python:3-alpine

WORKDIR /minecraft-box  
COPY . .

EXPOSE 25566 8080 8123

RUN pip install --no-cache-dir -r requirements.txt && \
    apk update && \
    apk add openjdk8 && \
    apk add bash && \
    apk add curl && \
    apk add ruby && \
    apk add ruby-full

VOLUME /minecraft-box  

CMD ["bin/start_server.sh"]
