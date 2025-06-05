#!/bin/bash
# this script will be run when manageBlogs.sh/task2.sh is run
DB_USER="postgres"
DB_PW="blog"
DB_HOST="db"
DB_NAME="blogserver"

DB_EXISTS=$(PGPASSWORD="$DB_PW" psql -h "$DB_HOST" -p 5432 -U "$DB_USER" -d postgres -tAq -c \
    "SELECT 1 FROM pg_database WHERE datname='blog';")

if [[ "$DB_EXISTS" == 1 ]]; then
    exit 0
else
    PGPASSWORD="$DB_PW" psql -h "$DB_HOST" -p 5432 -U "$DB_USER" -d postgres -c "CREATE DATABASE blog OWNER $DB_USER;"
fi

CREATE_TABLE="
            CREATE TABLE IF NOT EXISTS blog (
                id SERIAL PRIMARY KEY,
                file_name VARCHAR(50) UNIQUE NOT NULL,
                publish_status BOOLEAN,
                categories TEXT
            );
        "
PGPASSWORD="$DB_PW" psql -h "$DB_HOST" -p 5432 -U "$DB_USER" -d "$DB_NAME" -c "$CREATE_TABLE"

adding_metadata()
{
    file_name="$1"
    publish_status="$2"
    cat_order="$3"
    psql -d "$DB_NAME" -U "$DB_USER" -c "INSERT INTO blog (file_name, publish_status, cat_order) VALUES ('$file_name', $publish_status, ARRAY[$cat_order]) ON CONFLICT (file_name) DO NOTHING;"
}

#assuming this script is in the same directory as the author
YAML_FILE="./sysad-1-blog.yaml"
declare -A CATEGORIES=(
  [1]="Sports"
  [2]="Cinema"
  [3]="Technology"
  [4]="Travel"
  [5]="Food"
  [6]="Lifestyle"
  [7]="Finance"
)

n=$(yq e '.blogs | length' "$YAML_FILE")

for ((i=0; i<n; i++)); do
  file_name=$(yq e ".blogs[$i].file_name" "$YAML_FILE")
  publish_status=$(yq e ".blogs[$i].publish_status" "$YAML_FILE")
  IFS=',' read -ra ids <<< "$(yq e ".blogs[$i].cat_order[]" "$YAML_FILE" | paste -sd ",")"
  cat_names_list=()
  for id in "${ids[@]}"; do
    cat_names+=("${CATEGORIES[$id]}")
  done

  IFS=','
  cat_string="${cat_names[*]}"

  adding_metadata "$file_name" "$publish_status" "$cat_string"
done
