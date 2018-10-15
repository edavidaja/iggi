FROM rocker/rstudio

RUN sudo apt-get update && apt-get install -qq -y --no-install-recommends \
    libpoppler-cpp-dev poppler-utils libgit2-dev libxml2-dev libtesseract-dev \
    libleptonica-dev tesseract-ocr-eng
ENV MAKE='make -j 8'
COPY init.R DESCRIPTION packrat.lock /iggi/
WORKDIR /iggi
RUN R -e "install.packages('jetpack')"
RUN R -e "jetpack::install(deployment=TRUE)"
