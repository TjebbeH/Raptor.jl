#!/usr/bin/bash

git config --global credential.https://dev.azure.com.useHttpPath true
git config --global --add --bool push.autoSetupRemote true # dont need to do git push --set-upstream origin feature/branch anymore
git config --global core.autocrlf input
git config --global user.email "${GIT_MAIL}"
git config --global user.name "${GIT_EMAIL}"
julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'
mkdir -p ./src/raptor_timetable/data