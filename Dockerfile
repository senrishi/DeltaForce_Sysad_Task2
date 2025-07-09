FROM ubuntu:latest
WORKDIR /home
RUN mkdir -p /home/scripts /temp_loc
COPY ./sysad-1-users.yaml ./scripts
EXPOSE 5432
EXPOSE 80

#installing dependencies
RUN apt update && \
    apt install -y cron curl git nginx acl postgresql-16 postgresql-client-16 && \
    curl -L https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64  > /usr/bin/yq && \
    chmod +x /usr/bin/yq

#running task1 and copying task4 
COPY task1.sh ./scripts
RUN chmod +x /home/scripts/task1.sh \
    && ./scripts/task1.sh 

#running task2
COPY task2.sh /temp_loc
COPY copy_task2.sh ./scripts
RUN chmod +x /home/scripts/copy_task2.sh \
    && ./scripts/copy_task2.sh

#running task3
COPY censored.txt /temp_loc
COPY task3.sh /temp_loc
COPY copy_cen_task3.sh /temp_loc
RUN chmod +x /temp_loc/copy_cen_task3.sh \
    && /temp_loc/copy_cen_task3.sh
    
#running task4
COPY task4.sh /temp_loc
COPY copy_task4.sh /temp_loc
RUN chmod +x /temp_loc/copy_task4.sh \
    && /temp_loc/copy_task4.sh

#running task5
COPY task5.sh /temp_loc
COPY cronjob.sh ./scripts
COPY cronjob.txt /etc/cron.d/cronjob-task5
RUN chmod 0644 /etc/cron.d/cronjob-task5 \
    && touch /var/log/cron.log
CMD ["bash", "-c", "cron && tail -f /var/log/cron.log"]

COPY nginx_conf.sh ./scripts
RUN chmod +x /home/scripts/nginx_conf.sh

COPY db_users.sh /temp_loc
COPY copy_dbusers.sh /temp_loc
RUN chmod +x /temp_loc/copy_dbusers.sh \
    && /temp_loc/copy_dbusers.sh

COPY db_postgre.sh ./scripts
