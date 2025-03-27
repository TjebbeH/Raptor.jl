#!/usr/bin/bash

git config --global credential.https://dev.azure.com.useHttpPath true
git config --global --add --bool push.autoSetupRemote true # dont need to do git push --set-upstream origin feature/branch anymore
git config --global core.autocrlf input
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"
git config --global --add safe.directory /workspaces/Raptor.jl