FROM hyku-base-no-onbuild AS hyku-knap-base

ARG APP_PATH=.
COPY --chown=1001:101 $APP_PATH/.git /app/samvera/hyrax-webapp/.git
COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp
RUN chmod +x /app/samvera/hyrax-webapp/bin/*.sh

# No need to run bundle install again — base image already did

# -- Web image --
FROM hyku-knap-base AS hyku-web
ENV K8=no

ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummytoken \
    DB_ADAPTER=nulldb \
    DB_URL=postgresql://fake \
    RAILS_SERVE_STATIC_FILES=true

RUN bundle exec rake assets:precompile && yarn install

CMD ["./bin/web"]

# -- Worker image --
FROM hyku-web AS hyku-worker
CMD ["./bin/worker"]
