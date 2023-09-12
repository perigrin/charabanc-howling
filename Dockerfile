FROM perl:latest

RUN apt-get update \
  && apt-get install -y postgresql-client

RUN cpanm Carton \
 && mkdir -p /usr/local/registry

WORKDIR /usr/local/registry

COPY . /usr/local/registry
RUN rm -rf /usr/local/registry/local

RUN carton install --deployment

ENTRYPOINT ["carton", "exec"]
CMD ["morbo", "app.pl"]
