#!/bin/bash

if [ ! -d "$HOME/.config/QtProject/qtcreator/templates/wizards/classes" ]; then
    echo "Creating wizards folder: $HOME/.config/QtProject/qtcreator/templates/wizards/classes/"
    mkdir -p $HOME/.config/QtProject/qtcreator/templates/wizards/classes/
fi
if [ ! -d "$HOME/.config/QtProject/qtcreator/templates/wizards/projects" ]; then
    echo "Creating wizards folder: $HOME/.config/QtProject/qtcreator/templates/wizards/projects/"
    mkdir -p $HOME/.config/QtProject/qtcreator/templates/wizards/projects/
fi

echo "Copying XPCF classes wizards to: $HOME/.config/QtProject/qtcreator/templates/wizards/classes/xpcf"
cp -r classes/xpcf $HOME/.config/QtProject/qtcreator/templates/wizards/classes/

echo "Copying XPCF projects wizards to: $HOME/.config/QtProject/qtcreator/templates/wizards/projects/"
cp -r projects/xpcf\ module $HOME/.config/QtProject/qtcreator/templates/wizards/projects
cp -r projects/xpcf\ application $HOME/.config/QtProject/qtcreator/templates/wizards/projects

echo "Copying REMAKEN projects wizards to: $HOME/.config/QtProject/qtcreator/templates/wizards/projects/"
cp -r projects/remaken $HOME/.config/QtProject/qtcreator/templates/wizards/projects

if [ ! -d "$HOME/.remaken/rules/" ]; then
    echo "Creating default remaken rules folder: $HOME/.remaken/rules/"
    mkdir -p $HOME/.remaken/rules
fi

if [ ! -d "$HOME/.remaken/rules/qmake" ]; then
    if ! [ -x "$(which git)" ]; then
        echo "WARNING : git not available and default remaken qmake rules folder doesn't exist in $HOME/.remaken/rules/qmake"
        echo "==> Check your remaken installation"
        echo "==> NOTE: XPCF module wizard will not find default remaken qmake rules, you may should to either:"
        echo "    - install git and relaunch this script"
        echo "    - use local qmake rules inside your project folder"
        echo "    - reinstall remaken before using the wizard"
        # replace with apt-get/brew ??
    else
        echo "Cloning default rules from github https://github.com/b-com-software-basis/builddefs-qmake to  $HOME/.remaken/rules/qmake"
        git clone https://github.com/b-com-software-basis/builddefs-qmake $HOME/.remaken/rules/qmake
    fi
fi
