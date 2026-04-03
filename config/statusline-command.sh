#!/bin/sh
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

cyan='\033[36m'
green='\033[32m'
orange='\033[38;5;208m'
red='\033[31m'
dim='\033[2m'
reset='\033[0m'

# Returns a color escape based on percentage
pct_color() {
  p=$1
  if [ "$p" -ge 80 ]; then printf '%s' "$red"
  elif [ "$p" -ge 50 ]; then printf '%s' "$orange"
  else printf '%s' "$green"
  fi
}

if [ -n "$used" ]; then
  pct=$(printf "%.0f" "$used")
  bar_color=$(pct_color "$pct")

  bar_width=10
  filled=$(( pct * bar_width / 100 ))
  empty=$(( bar_width - filled ))
  bar=""
  i=0
  while [ $i -lt $filled ]; do bar="${bar}█"; i=$(( i + 1 )); done
  i=0
  while [ $i -lt $empty ]; do bar="${bar}▒"; i=$(( i + 1 )); done

  printf "${cyan}%s${reset} [${bar_color}%s${reset}] ${bar_color}%s%%${reset}" "$model" "$bar" "$pct"
else
  printf "${cyan}%s${reset}" "$model"
fi

# Rate limits — only shown once data is available (after first API response)
if [ -n "$five_hour" ] || [ -n "$seven_day" ]; then
  printf " ${dim}|${reset}"
  if [ -n "$five_hour" ]; then
    p=$(printf "%.0f" "$five_hour")
    c=$(pct_color "$p")
    printf " ${dim}5h:${reset}${c}%s%%${reset}" "$p"
  fi
  if [ -n "$seven_day" ]; then
    p=$(printf "%.0f" "$seven_day")
    c=$(pct_color "$p")
    printf " ${dim}7d:${reset}${c}%s%%${reset}" "$p"
  fi
fi
