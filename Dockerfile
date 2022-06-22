ARG RVM_RUBY_VERSIONS="3.1.2"
FROM kingdonb/docker-rvm:20220620
LABEL maintainer="Kingdon Barrett <kingdon@weave.works>"
ENV APPDIR="/home/${RVM_USER}/simplest-commitbee"
# ENV SCHEMA="sqlite.schema"
# ENV STATE="beegraph.sqlite"

# install 'ex' to do some manhandling of the schema file for loading
RUN apt-get update && apt-get install -y --no-install-recommends \
  manpages vim-tiny && apt-get clean && rm -rf /var/lib/apt/lists/*

# set the time zone
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  tzdata && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN echo "America/New_York" > /etc/timezone
RUN unlink /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN mkdir ${APPDIR}
WORKDIR ${APPDIR}
## migrate the database
# COPY ${SCHEMA} /tmp/
# RUN touch /tmp/${SCHEMA} && ex -c '1d2|$d|x' /tmp/${SCHEMA}
# RUN sqlite3 ${STATE} < /tmp/${SCHEMA}

## RVM_USER is permitted to create files and may write to $STATE
# RUN chown ${RVM_USER} ${APPDIR}/${STATE} ${APPDIR}
# RVM_USER is permitted to create files
RUN chown ${RVM_USER} ${APPDIR}
RUN chsh ${RVM_USER} -s /usr/bin/bash
ENV WORKSPACE_DIR=/Users/kingdonb/projects/personal
RUN mkdir -p ${WORKSPACE_DIR} && \
  ln -s /home/${RVM_USER}/simplest-commitbee  ${WORKSPACE_DIR}
USER ${RVM_USER}
# ENV RUBY=3.1.2

# include the ruby-version and Gemfile for bundle install
ADD --chown=rvm Gemfile Gemfile.lock .ruby-version ${APPDIR}/

RUN  bash --login -c 'bundle install'
ADD --chown=rvm .   ${APPDIR}

# include the app source code
# web.rb for default health checking on Proctype "cmd"
CMD  bash --login -c 'bundle exec ruby ./web.rb'
EXPOSE 5000
