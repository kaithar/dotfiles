FROM xev-base:latest

USER root

RUN apt-get update && apt-get install -y thunderbird

USER developer
ENV HOME /home/developer
CMD /usr/bin/thunderbird
