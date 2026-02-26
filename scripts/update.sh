#!/usr/bin/env bash

set -e

# Name of the macro to inject into the template
MACRO_NAME="AddDefaultTags"
# The base url for the cloudformation templates
CLOUDFORMATION_BASE_URL="https://s3.amazonaws.com/solutions-reference/instance-scheduler-on-aws/latest"
# A list of the cloudformation templates to download
CLOUDFORMATION_URLS=(
  "$CLOUDFORMATION_BASE_URL/instance-scheduler-on-aws-remote.template"
  "$CLOUDFORMATION_BASE_URL/instance-scheduler-on-aws.template"
)
# The path to the sed command
SED=$(which gsed || which sed)

usage() {
  cat << EOF
  Usage: $0
    -m, --macro      Name of the macro to inject into the template (default: $MACRO_NAME)
    -h, --help       Show this help message
EOF
  if [[ ${#} -gt 0 ]]; then
    echo -e "Error: ${*}"
    exit 1
  fi
  exit 0
}

# Download the template to the temp directory
download-cloudformation-template() {
  local url=$1
  local filename

  filename=$(basename "${url}")

  echo -e "Downloading $url to $TEMP_DIR/$filename"

  if ! curl -s -o "$TEMP_DIR/$filename" "$url"; then
    echo -e "Failed to download $url"
    exit 1
  fi
}

# Responsible for converting the json cloudformation template to yaml
convert-cloudformation-template() {
  local filename=$1
  local output_filename=$2

  echo -e "Converting $filename to YAML"

  if ! yq -P "$filename" | grep -v AWSTemplateFormatVersion >> "$output_filename"; then
    echo -e "Failed to convert $filename to YAML"
    exit 1
  fi

  echo -e "Converted $filename to YAML"
}

# Responsible for retrieving, converting and saving the cloudformation template
update-cloudformation-template() {
  local url=$1

  filename=$(basename "${url}")
  # First we download the template
  download-cloudformation-template "$url"
  # Then we convert the template to YAML
  convert-cloudformation-template "$TEMP_DIR/${filename}" "$TEMP_DIR/${filename}.yaml.tmp"
  # Replace all the ${ with $${
  "$SED" -i 's/\${/\$\${/g' "$TEMP_DIR/${filename}.yaml.tmp"
  # Add the template to the top of the file
  echo -e "Adding the template to the top of the file"
  cat << EOF > "$TEMP_DIR/${filename}.yaml"
---
#
## Source: $url
#
EOF
    cat << EOF >> "$TEMP_DIR/${filename}.yaml"
AWSTemplateFormatVersion: 2010-09-09
%{ if enable_macro ~}
Transform: \${ macro_name }
%{ endif ~}
EOF
  ## Copy the temporary file to the final file
  cat "$TEMP_DIR/${filename}.yaml.tmp" >> "$TEMP_DIR/${filename}.yaml"
  # Move the template to the current directory
  mv "$TEMP_DIR/${filename}.yaml" "modules/scheduler/assets/cloudformation/${filename}"
}

# Parse the command line arguments
while [[ ${#} -gt 0 ]]; do
  case $1 in
    -h | --help)
      usage
      ;;
    *)
      usage "Unknown argument: $1"
      ;;
  esac
done

# Create a temp directory
TEMP_DIR=$(mktemp -d)
# Ensure we delete the temp directory
# shellcheck disable=SC2064
trap "rm -rf ${TEMP_DIR} || true" EXIT

# Update the templates
for url in "${CLOUDFORMATION_URLS[@]}"; do
  update-cloudformation-template "$url"
done

