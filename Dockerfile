# VERSION: 0.1.0
# DESCRIPTION: Basic extensible Jupyter Notebook/Lab Container
# BUILD: docker build --rm -t docker-jupyter-extensible .

FROM jupyter/scipy-notebook

# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Define locales.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

USER root

# install the locales you want to use
RUN set -ex \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && sed -i 's/^# pt_BR.UTF-8 UTF-8$/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen en_US.UTF-8 pt_BR.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

USER $NB_UID

# install Python packages you often use
RUN set -ex \
    && conda install --quiet --yes \
    # choose the python packages you need
    'plotly==4.14.3' \
    'folium==0.11.0' \
    'geopandas==0.9.0' \
    'python-slugify[unidecode]==4.0.1' \
    'pymongo=3.12.0' \
    && conda clean --all -f -y \
    # install jupyter lab extensions you need
    && jupyter labextension install jupyterlab-plotly@4.14.3 --no-build \
    && jupyter lab build -y \
    && jupyter lab clean -y \
    && rm -rf "/home/${NB_USER}/.cache/yarn" \
    && rm -rf "/home/${NB_USER}/.node-gyp" \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}"

# install msodbcsql17
RUN apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
    curl

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get install -yqq msodbcsql17 \

# install other dependencies
#
# For quick experimentation, you can also install Python packages with
# pip by including the package references in requirements.txt.
# However, the recommended way to add packages is in the section above.
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

