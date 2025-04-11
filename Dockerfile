FROM hyku-base-no-onbuild AS hyku-knap-base

ARG APP_PATH=.
COPY --chown=1001:101 $APP_PATH/.git /app/samvera/hyrax-webapp/.git
COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp

# No need to run bundle install again — base image already did

# -- Web image --
FROM hyku-knap-base AS hyku-web
ENV K8=no

RUN RAILS_ENV=production \
    SECRET_KEY_BASE=`bin/rake secret` \
    DB_ADAPTER=nulldb \
    DB_URL='postgresql://fake' \
    bundle exec rake assets:precompile && \
    yarn install

CMD ./bin/web

# -- Worker image --
FROM hyku-web AS hyku-worker
CMD ./bin/worker
