FROM centos:8 as centos8builder

WORKDIR /APP
ADD . /APP
RUN bash /APP/centos8.prereqs.sh
RUN /usr/bin/scl enable gcc-toolset-10 make



FROM centos8builder
CMD ["/usr/bin/scl", "enable", "gcc-toolset-10", "bash"]

