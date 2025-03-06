#!/bin/bash

RED="\033[0;31m"
RESET="\033[0m"

echo -e "${RED}    ▄    ■  █ ▗▞▀▜▌▗▖    ▄▄▄ █  ▐▌   ■  ▗▞▀▚▖ ▄▄▄ ${RESET}"
echo -e "${RED}    ▄ ▗▄▟▙▄▖█ ▝▚▄▟▌▐▌   █    ▀▄▄▞▘▗▄▟▙▄▖▐▛▀▀▘█    ${RESET}"
echo -e "${RED}    █   ▐▌  █      ▐▛▀▚▖█           ▐▌  ▝▚▄▄▖█    ${RESET}"
echo -e "${RED} ▗▄▖█   ▐▌  █      ▐▙▄▞▘            ▐▌            ${RESET}"
echo -e "${RED}▐▌ ▐▌   ▐▌                          ▐▌            ${RESET}"
echo -e "${RED} ▝▀▜▌                                              ${RESET}"
echo -e "${RED}▐▙▄▞▘                                              ${RESET}"
echo -e "${RED}      by KL3FT3Z $(echo -e "\033[0;34m")https://github.com/toxy4ny"

read -p "Enter Domain (Example: http://gitlab.local.test): " BASE_URL
PROJECTS_LIST="projects.txt"
USERS_LIST="users.txt"
OUTPUT_FILE_PROJECTS="found_projects.txt"
OUTPUT_FILE_USERS="found_users.txt"
PAUSE_DURATION=60
SEARCH_PATH_PROJECTS="/search?scope=projects&search="
SEARCH_PATH_USERS="/search?scope=users&search="

> "$OUTPUT_FILE_PROJECTS"
> "$OUTPUT_FILE_USERS"

echo "Check Public projects and Users for: $BASE_URL"

check_base_search_path() {
    local search_url="${BASE_URL}$1"

    response=$(curl -s -w "%{http_code}" -o /dev/null "$search_url")
    http_status="${response: -3}"

    if [ "$http_status" -eq 200 ]; then
        echo -e "\e[92m[+]\e[0m The basic search path is available! Let's go! $search_url"
    else
        echo -e "\e[91m[-]\e[0m The basic search path is unavailable: $search_url. HTTP code: $http_status"
    fi
}

check_element() {
    local element=$1
    local search_path=$2
    local output_file=$3
    local search_url="${BASE_URL}${search_path}${element}"
    
    response=$(curl -s -w "%{http_code}" -o temp_response.txt "$search_url")
    http_status="${response: -3}"

    if [ "$http_status" -eq 429 ]; then
        echo -e "\e[93m[-]\e[0m Too many requests on server. Hold on $PAUSE_DURATION sec. Element: $element"
        sleep $PAUSE_DURATION
        return 1
    fi

    if grep -q "No results found" temp_response.txt; then
        echo -e "\e[91m[-]\e[0m Element $element not found. HTTP code: $http_status"
    else
        echo -e "\e[92m[+]\e[0m found Element: $element. HTTP code: $http_status"
        echo "$search_url" >> "$output_file"
    fi

    rm -f temp_response.txt
    return 0
}

echo "MENU"
echo "1. Check Public projects."
echo "2. Check Users."
read -p "You're choice?: " choice

case $choice in
    1)
        check_base_search_path "$SEARCH_PATH_PROJECTS"
        while IFS= read -r project
        do
            while ! check_element "$project" "$SEARCH_PATH_PROJECTS" "$OUTPUT_FILE_PROJECTS"; do
                :
            done
        done < "$PROJECTS_LIST"
        echo "The project verification is completed. The results are saved in $OUTPUT_FILE_PROJECTS."
        ;;
    2)
        check_base_search_path "$SEARCH_PATH_USERS"
        while IFS= read -r user
        do
            while ! check_element "$user" "$SEARCH_PATH_USERS" "$OUTPUT_FILE_USERS"; do
                : 
            done
        done < "$USERS_LIST"
        echo "User verification is completed. The results are saved in $OUTPUT_FILE_USERS."
        ;;
    *)
        echo "Wrong choice. Script shutdown."
        ;;
esac