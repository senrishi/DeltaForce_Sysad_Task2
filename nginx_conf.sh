#!/bin/bash

YAML_FILE="/home/scripts/sysad-1-users.yaml"
NGINX_CONF="/etc/nginx/conf.d/blogs.conf"

# cat and echo commands used to automatically create nginx config files based on the author's presence,
# whether they are available or removed. nginx.conf file is automatically overwritten whenever a change to
# yaml_file occurs.
echo "
server 
    {
        listen 80 default_server;
        listen [::]:80 default_server;
    }
location / {
     return 444;
    }
}
" > "$NGINX_CONF"

cat $YAML_FILE | yq -r '.authors[].username' | while read -r username; do
    echo "    # $username" >> $NGINX_CONF
    echo "    server_name ${username}.blog.in;" >> $NGINX_CONF
        # APPROPRIATE CHANGES FOR THE ROOT DIRECTORY HAVE BEEN MADE TO manageBlogs/task2.sh file
    echo "    root /var/www/blogs_public/$username/public;" >> $NGINX_CONF
    echo "" >> "$NGINX_CONF"
    
    echo "    location ~ \\.txt\$ {" >> "$NGINX_CONF"
    echo "        types {};" >> "$NGINX_CONF"
    echo "        default_type text/plain;" >> "$NGINX_CONF"
    echo "    }" >> "$NGINX_CONF"
    echo "" >> "$NGINX_CONF"
    
    echo "    location ~ ^/download/(.*\\.txt)\$ {" >> "$NGINX_CONF"
    echo "        alias /var/www/blogs_public/$username/public/\$1;" >> "$NGINX_CONF"
    echo "        add_header Content-Disposition \"attachment; filename=\"\$1\"\";" >> "$NGINX_CONF" 
    echo "        autoindex off;" >> "$NGINX_CONF"
    echo "    }" >> "$NGINX_CONF"
    echo "" >> "$NGINX_CONF"
    
done
echo "    location / {" >> "$NGINX_CONF" 
echo "        deny all;" >> "$NGINX_CONF"
echo "    }" >> "$NGINX_CONF"
echo "}" >> "$NGINX_CONF"

nginx -t && exec nginx -g 'daemon off;'