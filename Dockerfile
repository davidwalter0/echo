FROM davidwalter/debian-stretch-slim
COPY bin/echo /echo
EXPOSE 8888 
CMD [ "/echo" ]
