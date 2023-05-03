#!/bin/bash

red=$'\e[31m'
green=$'\e[32m'
reset=$'\e[0m'

body='{
  "description": "'${version_description}'",
  "name": "'${version_name}'",
  "archived": false,
  "project": "'${project_prefix}'",
'

today=$(date +'%Y-%m-%d')

if [ "$version_released" == "yes" ]; 
then
body+='  "released": true,
  "releaseDate": "'$today'",
'
fi
body+='  "startDate": "'$today'"
}'


res="$(curl -u $jira_user:$jira_token -X POST -H 'Content-Type: application/json' --data-raw "${body}" https://${jira_domain}/rest/api/2/version)"

JIRA_VERSION_URL=""

if [[ $res == *"errorMessages"* ]]; then
  error="$(echo $res | jq '.errors .name' | tr -d '"')"
  echo $'\t'"${red}❗️ Failed $error ${reset}"
else
  name="$(echo $res | jq '.name' | tr -d '"')"
  id="$(echo $res | jq '.id' | tr -d '"')"
  description="$(echo $res | jq '.description' | tr -d '"')"
  projectId="$(echo $res | jq '.projectId' | tr -d '"')"
  project="$(echo $res | jq '.project' | tr -d '"')"
  self="$(echo $res | jq '.self' | tr -d '"')"
  echo $'\t'"${green}✅ Success!${reset}"
  echo "Id = " $id
  echo "Name = " $name
  echo "Description = " $description
  echo "Project ID = " $projectId
  echo "Project = " $project
  echo "API = " $self

  JIRA_VERSION_URL="https://${jira_domain}/projects/${project_prefix}/versions/${id}"
  echo "JIRA VERSION = " $JIRA_VERSION_URL
fi

envman add --key JIRA_VERSION_URL --value "${JIRA_VERSION_URL}"



