FROM rocker/rstudio

RUN sudo apt-get update && apt-get install libpoppler-cpp-dev poppler-utils
RUN 

