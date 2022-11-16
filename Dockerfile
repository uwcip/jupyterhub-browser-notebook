FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.8.5

# github metadata
LABEL org.opencontainers.image.source=https://github.com/uwcip/jupyterhub-browser-notebook

USER root

# install updates and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
# install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver && \
    apt-get clean && rm /tmp/chromedriver_linux64.zip

# install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

#running the following as notebook user
USER ${NB_UID}

# install Python3 packages
RUN conda install --quiet --yes \
    "beautifulsoup4" \
    "dateparser" \
    "lxml" \
    "pandas" \
    "selenium" \
    "fake-useragent" \
    "scrapy" \
    "newspaper3k" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true
    
# install more python packages not in conda
#  - justext
#  - telethon
#  - undetected-chromedriver
#  - trafilatura
#  - pyktok
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
    "requests-html" \    
    "browser_cookie3" \    
    "pyktok" \
    "telethon" \
    "jusText" \
    "undetected-chromedriver" \
    "trafilatura" \
#    "jupyterlab_scheduler" \
    && fix-permissions "/home/${NB_USER}" \
    && true


# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
