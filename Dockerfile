FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.8.3

# github metadata
LABEL org.opencontainers.image.source=https://github.com/uwcip/jupyterhub-browser-notebook

USER root

# install updates and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update && apt-get -y upgrade && \
    # dvipng+cm-super for latex labels
    apt-get install -y --no-install-recommends dvipng cm-super && \
    # tesseract for OCR work
    apt-get install -y --no-install-recommends tesseract-ocr-all && \
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
    "requests-html" \
    "undetected-chromedriver" \
    "fake-useragent" \
    "scrapy" \
    "pyktok" \
    "telethon" \
    "jusText" \
    "newspaper3k" \
    "trafilatura" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true


# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
