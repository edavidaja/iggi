FROM rocker/rstudio

RUN sudo apt-get update && apt-get install libpoppler-cpp-dev poppler-utils
COPY . /iggi
WORKDIR /iggi
RUN Rscript init.R

