SCRIPT="/temp_loc/task5.sh"
DIR="/home/admin"
YAML_FILE="/home/scripts/sysad-1-users.yaml"

username=$(yq e '.admins[].username' "$YAML_FILE")

for user in username; do
    cp "$SCRIPT" "$DIR/$user"
done
