FROM python:alpine3.18

COPY entrypoint /entrypoint

ENTRYPOINT [ "/entrypoint" ]

RUN adduser -D -u 54000 radio && \
        apk update && \
        apk add git gcc musl-dev libffi-dev openssl-dev cargo mariadb-dev && \
        pip install --upgrade pip && \
        pip cache purge && \
        cd /opt && \
        git clone https://github.com/ShaYmez/RYSEN-SP-SELFCARE.git rysen-sp-selfcare && \
        cd /opt/rysen-sp-selfcare && \
        pip install --no-cache-dir -r requirements.txt && \
        apk del git gcc musl-dev && \
        chown -R radio: /opt/rysen-sp-selfcare

USER radio

ENTRYPOINT [ "/entrypoint" ]
