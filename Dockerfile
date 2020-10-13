# Install Python
FROM python:3-alpine

WORKDIR /minecraft-box
COPY . .

RUN pip install --no-cache-dir -r requirements.txt && \
    apk update && \
    apk add openjdk8 && \
    apk add bash && \
    apk add curl && \
    apk add ruby && \
    apk add ruby-full

CMD ["bin/start_server.sh"]
