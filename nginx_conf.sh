#!bin/bash

YAML_FILE="/home/scripts/sysad-1-users.yaml"
NGINX_CONF="/etc/nginx/sites-available/blogs.conf"
touch $NGINX_CONF
echo "#nginx config for serving blogs
" > $NGINX_CONF

cat $YAML_FILE | yq -r '.authors[].username' | while read -r username; do
    
    sudo setfacl -R -m u:www-data:rx /home/authors/$username/public
    sudo setfacl -m u:www-data:x /home/authors/$username/public

    echo "server {
        listen 80;
        listen [::]:80;
        server_name $username.blogs.in;
        root /home/authors/$username/public;
        location ~ \.txt$ {
            try_files $uri =404;
        }
        location ~ ^/download/(.*\.txt)$ {
            alias /home/authors/$username/public/\$1;
            add_header Content-Disposition 'attachment; filename=\"\$1\"';
        }
        
    }
    " >> $NGINX_CONF
done

ln -s $NGINX_CONF /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx