FROM ghcr.io/uwcip/jupyterhub-base-notebook:v1.8.3

# github metadata
LABEL org.opencontainers.image.source=https://github.com/uwcip/jupyterhub-browser-notebook

USER root

# install updates and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update && apt-get -y upgrade && \
    # ffmpeg for matplotlib anim & dvipng+cm-super for latex labels
    apt-get install -y --no-install-recommends ffmpeg dvipng cm-super && \
    # tesseract for OCR work
    apt-get install -y --no-install-recommends tesseract-ocr-all && \
    # Java for Spark
    apt-get install -y --no-install-recommends default-jdk && \
    # NLopt (non-linear optmization) package
    apt-get install -y --no-install-recommends libnlopt-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# install Python3 packages
RUN conda install --quiet --yes \
    "beautifulsoup4" \
    "dateparser" \
    "gensim" \
    "pandas" \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions "/home/${NB_USER}" \
    && true

# ensure that we run the container as the notebook user
USER ${NB_UID}
WORKDIR ${HOME}
