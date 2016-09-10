#!/bin/bash
cd -- "$(dirname "$0")"
R -e "shiny::runApp('MedQuizzer', launch.browser=TRUE)"
