FROM xev-base:latest

USER root

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /

RUN apt-get update && \
    apt install -y /google-chrome-stable_current_amd64.deb

USER developer
ENV HOME /home/developer
CMD /usr/bin/google-chrome
