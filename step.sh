#!/bin/bash

red=$'\e[31m'
green=$'\e[32m'
reset=$'\e[0m'

body='{
  "fields": {
    "description": "'${ticket_description}'",
    "summary": "'${ticket_name}'",
    "project": {
      "key": "'${project_prefix}'"
    },
    "issuetype": {
      "id": "'${ticket_issue_type}'"
    }
  },
  "update": {}
}'

today=$(date +'%Y-%m-%d')

echo curl -u $jira_user:$jira_token -X POST -H 'Content-Type: application/json' --data-raw "${body}" https://${jira_domain}/rest/api/3/issue

echo $body

res="$(curl -u $jira_user:$jira_token -X POST -H 'Content-Type: application/json' --data-raw "${body}" https://${jira_domain}/rest/api/3/issue)"

echo $res

JIRA_TICKET_URL=""

if [[ $res == *"errorMessages"* ]]; then
  error="$(echo $res | jq '.errors .name' | tr -d '"')"
  echo $'\t'"${red}❗️ Failed $error ${reset}"
else
  id="$(echo $res | jq '.id' | tr -d '"')"
  key="$(echo $res | jq '.key' | tr -d '"')"
  self="$(echo $res | jq '.self' | tr -d '"')"
  echo $'\t'"${green}✅ Success!${reset}"
  echo "Id = " $id
  echo "key = " $key

  JIRA_TICKET_URL="https://${jira_domain}/browse/${key}"
  echo "JIRA TICKET = " $JIRA_TICKET_URL
fi

envman add --key JIRA_TICKET_URL --value "${JIRA_TICKET_URL}"



