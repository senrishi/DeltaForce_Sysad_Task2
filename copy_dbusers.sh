SCRIPT="/temp_loc/db_users"
DIR="/home/authors"
YAML_FILE="/home/scripts/sysad-1-users.yaml"

username=$(yq e '.authors[].username' "$YAML_FILE")

for user in username; do
    cp "$SCRIPT" "$DIR/$user"
done
