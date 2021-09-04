FROM centos:8 as stage1

WORKDIR /APP
ADD . /APP
RUN bash /APP/centos8.prereqs.sh


FROM stage1 as stage2
WORKDIR /APP
RUN id -a
USER nobody
RUN id -a
RUN /usr/bin/scl enable gcc-toolset-10 'make --debug=bj'
RUN /usr/bin/scl enable gcc-toolset-10 'make --debug=bj test'

FROM stage2
WORKDIR /APP/build.small
USER nobody
CMD ["/usr/bin/scl", "enable", "gcc-toolset-10", "bash"]
