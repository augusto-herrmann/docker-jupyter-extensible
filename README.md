
# Extensible Docker image for Jupyter Notebook/Lab

Most tutorials for using Jupyter Notebook or Jupyter Lab end when you get
Jupyter running. But, in real world applications, you will also want to
set up your own system configuration parameters, install your own system and
Python packages, and it may not be obvious how to do it.

This repository intends to show you an example of a Docker file where you
can configure the packages you want and then build your own Docker image.
Here we are going to use `jupyter/scipy-notebook` as a base image, but you can
easily change that by editing the `Dockerfile`. The system configuration and
packages installed are also intended as examples for you to edit.

## Getting started

1. Install Docker.

2. Edit the `Dockerfile` and choose a base image. The default is:

   ```dockerfile
   FROM jupyter/scipy-notebook
   ```

   which includes [Pandas](https://pandas.pydata.org/),
   [NumPy](https://numpy.org/) and a few other things. To find a Docker image
   that best suits your needs, take a look at the
   [Jupyter Docker Stacks documentation](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html).

3. At the following section of the `Dockerfile`, choose the system
   configuration you want to do. In this example, we configure the system
   locales to use both `en_US.UTF-8` (English, US) and `pt_BR.UTF-8`
   (Brazilian Portuguese) locales.
   
   ```dockerfile
   # install the locales you want to use
   RUN set -ex \
      && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
      && sed -i 's/^# pt_BR.UTF-8 UTF-8$/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen \
      && locale-gen en_US.UTF-8 pt_BR.UTF-8 \
      && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
   ```

4. At the following section of the `Dockerfile`, choose the Python packages
   and
   [Jupyter Lab extensions](https://jupyterlab.readthedocs.io/en/stable/user/extensions.html)
   you need. For this example, we're using the data visualization tool
   [Plotly](https://plotly.com/python/) and the map plotting package
   [Folium](https://python-visualization.github.io/folium/).
   
   ```dockerfile
   # install Python packages you often use
   RUN set -ex \
      && conda install --quiet --yes \
      # choose the python packages you need
      'plotly==4.14.3' \
      'folium==0.11.0' \
      && conda clean --all -f -y \
      # install jupyter lab extensions you need
      && jupyter labextension install jupyterlab-plotly@4.9.0 --no-build \
      && jupyter lab build -y \
      && jupyter lab clean -y \
      && rm -rf "/home/${NB_USER}/.cache/yarn" \
      && rm -rf "/home/${NB_USER}/.node-gyp" \
      && fix-permissions "${CONDA_DIR}" \
      && fix-permissions "/home/${NB_USER}"
   ```

   Every time you want to install a new Python package, you must edit this file
   again and also execute the next step.

5. Build the Docker container with the following command:

   ```bash
   docker build --rm -t docker-jupyter-extensible .
   ```

   This should take a while to finish.

6. Create a `.env` file so that the container can use the same user
   permissions as your user:
   
   ```bash
   printf "UID=$(id -u)\nGID=$(id -g)\n" > .env
   ```

   This will allow you to use the `notebooks` folder both inside and
   outside the container.

7. Now you're set to go! Every time you want to start Jupyter, start from
   this step.
   
   Run the container with
      
   ```bash
   docker-compose up
   ```

   **Note:** After you have something important in the `notebooks` folder, I
   highly recommend you back it up often. The container once for me deleted
   the files in there automatically for some reason when I was trying to
   figure out how to set up those containers. YOU HAVE BEEN WARNED. I'm in no
   way responsible if you lose your files.

8. Pay attention to the terminal and look for a link starting with
   `http://127.0.0.1:8888` that also contains an access token. Open this
   link on a browser to use Jupyter Notebook. If you want to use Jupyter Lab,
   just change the URL afterwards to `http://127.0.0.1:8888/lab`.

