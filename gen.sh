#!/bin/bash
green=$(tput setaf 2)
red=$(tput setaf 1)
flutter pub get
flutter pub run build_runner build
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "${green}GEN SUCCESS"
else
  echo "${red}Try Delete Conflicting Outputs"
  flutter pub run build_runner build --delete-conflicting-outputs
  RESULT_BUILD_DELETE=$?
  if [ $RESULT_BUILD_DELETE -eq 0 ]; then
  echo "${green}GEN SUCCESS"
  fi
fi


