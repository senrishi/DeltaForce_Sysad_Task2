#!/bin/bash

DB_USER="postgres"
DB_PW="blog"
DB_HOST="db"
DB_NAME="blogserver"


if [ "$(psql -l | grep "$DB_NAME" | wc -l)" -eq 1 ]; then
    echo "DB exists. Proceeding with the ops..."
else
    createdb -h "$DB_HOST" -p 5432 -U "$DB_USER" "$DB_NAME"
    # PGPASSWORD="$DB_PW" psql -h "$DB_HOST" -p 5432 -U "$DB_USER" -d postgres -c "CREATE DATABASE blog OWNER $DB_USER;"
fi

CREATE_TABLE="
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                username VARCHAR(50) UNIQUE NOT NULL,
                name VARCHAR(50) UNIQUE NOT NULL,
                role VARCHAR(50) UNIQUE NOT NULL
            );
        "
psql -u "$DB_USER" -d "$DB_NAME" -c "$CREATE_TABLE"

insert_user()
{
    username=$1
    name=$2
    role=$3

    psql -d "$DB_NAME" -U "$DB_USER" -c "INSERT INTO users (username, name, role) VALUES ('$username', '$name', '$role') ON CONFLICT (username) DO NOTHING;"
}

YAML_FILE="/home/scripts/sysad-1-users.yaml"

while IFS= read -r name && IFS= read -r username; do
  insert_user "$name" "$username" "admin"
done < <(yq e '.admins[].name' "$YAML_FILE"; yq e '.admins[].username' "$YAML_FILE")

while IFS= read -r name && IFS= read -r username; do
  insert_user "$name" "$username" "users"
done < <(yq e '.users[].name' "$YAML_FILE"; yq e '.users[].username' "$YAML_FILE")

while IFS= read -r name && IFS= read -r username; do
  insert_user "$name" "$username" "mods"
done < <(yq e '.mods[].name' "$YAML_FILE"; yq e '.mods[].username' "$YAML_FILE")

while IFS= read -r name && IFS= read -r username; do
  insert_user "$name" "$username" "authors"
done < <(yq e '.authors[].name' "$YAML_FILE"; yq e '.authors[].username' "$YAML_FILE")

psql -qtAX -c "SELECT username FROM users;" | while IFS= read -r username; do
    if ! yq -e 'any((.admins[], .users[], .authors[], .mods[]) | .username == "'"${username}"'")' "$YAML_FILE" &> /dev/null; then
        DELETE_SQL="DELETE FROM users WHERE username = '$username';"
        psql -d "$DB_NAME" -U "$DB_USER" -c "$DELETE_SQL"
    fi
done
