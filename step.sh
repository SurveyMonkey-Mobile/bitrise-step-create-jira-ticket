#!/bin/bash

red=$'\e[31m'
green=$'\e[32m'
reset=$'\e[0m'

body='{
  "fields": {
    "description": { 
      "content": [
        {
          "content": [
            {
              "text": "'${ticket_description}'",
              "type": "text"
            }
          ],
          "type": "paragraph"
        }
      ],
      "type": "doc",
      "version": 1
    },
    "summary": "'${ticket_name}'",
    "project": {
      "key": "'${project_prefix}'"
    },
    "issuetype": {
      "id": "'${ticket_issue_type}'"
    },
    "customfield_14945": {
      "id": "'${ticket_field_14945}'"
    },
    "customfield_12042": "'${ticket_field_12042}'",
    "customfield_12240": {
      "id": "'${ticket_field_12240}'"
    },
    "customfield_11141": {
      "emailAddress": "'${ticket_field_11141}'"
    },
    "customfield_10140": {
      "emailAddress": "'${ticket_field_10140}'"
    },
    "customfield_11143": {
      "emailAddress": "'${ticket_field_11143}'"
    },
    "customfield_12045": {
      "emailAddress": "'${ticket_field_12045}'"
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



