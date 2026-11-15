FROM legacy-node-toolchain:phase15
ARG YARN_VERSION=1.22.19
RUN npm install -g "yarn@${YARN_VERSION}" \
    && ln -s "$(npm prefix -g)/bin/yarn" /usr/local/bin/yarn
