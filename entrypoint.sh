#!/usr/bin/env bash

# $1 is the version provided
REGEX_VALIDATE_VERSION="^(latest)$|(^[0-9]+\.[0-9]+\.[0-9]+$)"

version=$1

if [[ -z $version ]]; then
    echo "no version provided"
    exit 1
elif [[ ! $version =~ $REGEX_VALIDATE_VERSION ]]; then
    echo "invalid version provided"
    exit 1
fi

cd $GITHUB_WORKSPACE

targetFile="cangulo.nuke.releasecreator-linux-x64.zip"
outputFolder="./cangulo.nuke.releasecreator"

echo "::group::downloading $targetFile"

if [[ $version == "latest" ]]; then
    echo "downloading latest version"
    url="https://github.com/cangulo/cangulo.nuke.releasecreator/releases/$version/download/$targetFile"
else
    echo "downloading version $version"
    url="https://github.com/cangulo/cangulo.nuke.releasecreator/releases/download/$version/$targetFile"
fi

echo "url: $url"
wget $url
if [[ $? -ne 0 ]]; then
    echo "error downloading file"
    exit 1
fi

echo "::endgroup::"

echo "::group::unzipping"

if [ -d "$outputFolder" ]; then
    rm -rf $outputFolder
fi

mkdir $outputFolder

chmod +x $targetFile
unzip $targetFile -d $outputFolder

rm ./$targetFile

echo "::endgroup::"

echo "::group::listing files with initial permissions"
ls -la $outputFolder
echo "::endgroup::"

echo "::group::changing permissions"
chmod +x -R $outputFolder/**
echo "::endgroup::"

echo "::group::listing files after permissions changed"
ls -la $outputFolder
echo "::endgroup::"
