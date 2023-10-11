#!/bin/zsh

get_config_value() {
  local key="$1"
  local default="$2"
  local value

  value=$(jq -r ".params.$key" < "dotfiles-config.json")
  if [[ $value == "null" || $value == "" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Read the file paths from the config file
FILE_PATHS=$(jq -r '.files[]' < "dotfiles-config.json")
GIT_EXE=$(get_config_value "GIT_EXE" "git")
REPO_DIR=$(get_config_value "REPO_DIR" "$HOME/dotfiles")

# Iterate over the file paths
while IFS= read -r FILE_PATH; do
  # Replace tilde with user home directory
  SOURCE_FILE_PATH="${FILE_PATH/#\~/$HOME}"
  DESTINATION_FILE_PATH="${REPO_DIR}/${FILE_PATH/#\~/src}"

  # If the file is a directory, create it and copy the contents
  # to the destination directory
  if [[ $DESTINATION_FILE_PATH == */ ]]; then
    mkdir -p $DESTINATION_FILE_PATH
    cp -r $SOURCE_FILE_PATH/* $DESTINATION_FILE_PATH
  else
    cp $SOURCE_FILE_PATH $DESTINATION_FILE_PATH
  fi
done <<< "$FILE_PATHS"

# If the script is run with the --automated or -a flag, and 
# there are changes to the repo, commit and push
if [[ $1 == "--automated" || $1 == "-a" ]]; then
  cd $REPO_DIR
  $GIT_EXE add .
  
  FILE_COUNT="$($GIT_EXE status --porcelain | wc -l)"
  COMMIT_MESSAGE_TITLE=" $(date +%Y-%m-%d\ %H:%M:%S) | Updated: "

  if [[ $FILE_COUNT -gt 1 ]]; then
    COMMIT_MESSAGE_TITLE+="Multiple files"
  else
    COMMIT_MESSAGE_TITLE+="$($GIT_EXE status --porcelain | awk '{print $2}')"
  fi

  $GIT_EXE commit -m "$COMMIT_MESSAGE_TITLE"
  $GIT_EXE push
fi
