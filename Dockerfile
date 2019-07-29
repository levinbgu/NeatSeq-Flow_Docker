############## SGE From gawbul/docker-sge ####################
FROM phusion/baseimage:0.9.15

# expose ports
EXPOSE 6444
EXPOSE 6445
EXPOSE 6446

# run everything as root to start with
USER root

# set environment variables
ENV HOME /root

# regenerate host ssh keys
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# add pin priority to some graphical packages to stop them installing and borking the build
RUN echo "Package: xserver-xorg*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences
RUN echo "Package: unity*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences
RUN echo "Package: gnome*\nPin: release *\nPin-Priority: -1" >> /etc/apt/preferences

# turn off password requirement for sudo groups users
RUN sed -i "s/^\%sudo\tALL=(ALL:ALL)\sALL/%sudo ALL=(ALL) NOPASSWD:ALL/" /etc/sudoers

# install required software as per README.BUILD
RUN apt-get update -y
#RUN apt-get upgrade -y
RUN apt-get install -y wget darcs git mercurial tcsh build-essential automake autoconf openssl libssl-dev munge libmunge2 libmunge-dev libjemalloc1 libjemalloc-dev db5.3-util libdb-dev libncurses5 libncurses5-dev libpam0g libpam0g-dev libpacklib-lesstif1-dev libmotif-dev libxmu-dev libxpm-dev hwloc libhwloc-dev openjdk-7-jre openjdk-7-jdk ant ant-optional javacc junit libswing-layout-java libxft2 libxft-dev libreadline-dev man gawk

# add files to container from local directory
ADD sge_auto_install.conf /root/sge_auto_install.conf
ADD docker_sge_init.sh /etc/my_init.d/01_docker_sge_init.sh
ADD sge_exec_host.conf /root/sge_exec_host.conf
ADD sge_queue.conf /root/sge_queue.conf
ADD pe_shared.conf /root/pe_shared.conf
RUN chmod ug+x /etc/my_init.d/01_docker_sge_init.sh

# change to home directory
WORKDIR $HOME


# download source tarball instead
RUN wget -c https://arc.liv.ac.uk/downloads/SGE/releases/8.1.8/sge-8.1.8.tar.gz
RUN tar -zxvf sge-8.1.8.tar.gz

# change working directory
WORKDIR $HOME/sge-8.1.8/source

# setup SGE env
ENV SGE_ROOT /opt/sge
ENV SGE_CELL default
RUN echo export SGE_ROOT=/opt/sge >> /etc/bashrc
RUN echo export SGE_CELL=default >> /etc/bashrc
RUN ln -s $SGE_ROOT/$SGE_CELL/common/settings.sh /etc/profile.d/sge_settings.sh

# install SGE
RUN mkdir /opt/sge
RUN useradd -r -m -U -d /home/sgeadmin -s /bin/bash -c "Docker SGE Admin" sgeadmin
RUN usermod -a -G sudo sgeadmin
RUN sh scripts/bootstrap.sh && ./aimk && ./aimk -man
RUN echo Y | ./scripts/distinst -local -allall -libs -noexit
WORKDIR $SGE_ROOT
RUN ./inst_sge -m -x -s -auto ~/sge_auto_install.conf \
    && /etc/my_init.d/01_docker_sge_init.sh && sed -i "s/HOSTNAME/`hostname`/" $HOME/sge_exec_host.conf \
    && /opt/sge/bin/lx-amd64/qconf -au sgeadmin arusers \
    && /opt/sge/bin/lx-amd64/qconf -Me $HOME/sge_exec_host.conf \
    && /opt/sge/bin/lx-amd64/qconf -Aq $HOME/sge_queue.conf \
    && /opt/sge/bin/lx-amd64/qconf -Ap $HOME/pe_shared.conf 

# return to home directory
WORKDIR $HOME




############## SSH From rastasheep/ubuntu-sshd ####################

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

#RUN mkdir /root/.ssh
EXPOSE 22 

############## CONDA From conda/miniconda2 ####################
RUN apt-get -qq -y install curl bzip2 \
    && curl -sSL https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=2 
    
ENV PATH /opt/conda/bin:$PATH

############## For NeatSeq-Flow ####################

RUN sed -ri 's/#X11UseLocalhost yes/X11UseLocalhost no/g' /etc/ssh/sshd_config
RUN apt-get install -y firefox x-window-system dbus-x11

RUN wget https://raw.githubusercontent.com/bioinfo-core-BGU/neatseq-flow-tutorial/master/NeatSeq_Flow_Tutorial_Install.yaml
RUN conda env create -f NeatSeq_Flow_Tutorial_Install.yaml

RUN wget http://neatseq-flow.readthedocs.io/en/latest/extra/NeatSeq_Flow_conda_env.yaml
RUN conda env create -n NeatSeq_Flow -f NeatSeq_Flow_conda_env.yaml

RUN conda clean --all --yes

RUN echo 'sgeadmin:sgeadmin' |chpasswd

ADD update_NeatSeqFlow.sh /etc/my_init.d/02_update_NeatSeqFlow.sh
RUN chmod ug+x /etc/my_init.d/02_update_NeatSeqFlow.sh

############## Clean ####################
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# start my_init on execution and pass bash to runit

ENV PATH /opt/sge/bin:/opt/sge/bin/lx-amd64/:/opt/sge/utilbin/lx-amd64:$PATH
RUN echo export PATH=/opt/sge/bin:/opt/sge/bin/lx-amd64/:/opt/sge/utilbin/lx-amd64:$PATH >> /etc/bashrc

RUN echo source activate NeatSeq_Flow >> /home/sgeadmin/.bashrc

USER sgeadmin

RUN mkdir -p /home/sgeadmin/.local/share/

USER root

ENTRYPOINT ["/sbin/my_init", "--"]

CMD ["/bin/bash"]
