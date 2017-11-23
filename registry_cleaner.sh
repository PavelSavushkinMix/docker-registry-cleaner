#!/usr/bin/env bash

KEEP_NUMBER=$1
REGISTRY_HOST=$2
LOGIN=
PASSWORD=
BASE_URL=http://$LOGIN:$PASSWORD@$REGISTRY_HOST/v2

# EXEC CURL QUERY TO REGISTRY
function curlExec {
    method="$1";
    shift;
    echo $(curl -X "$method" -Ls $BASE_URL/"$@");
}

# GET ALL REPOSITORIES
function getRepositories {
    echo $(curlExec "GET" _catalog/);
}

# GET ALL TAGS
function getTags {
    echo $(curlExec "GET" "$1"/tags/list);
}

# GET DIGEST FOR TAG
function getDigest {
    echo $(curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -LIs "$BASE_URL/$1/manifests/$2" | grep "Docker-Content-Digest" | cut -d ' ' -f 2);
}

# GET TAGS AND CALL FUNC TO DELETE NO NEED
function repositoryCleanup {
    response=$(getTags $repoName);
    tags=($(echo $response | jq -r '.tags[]' | sort -V | tr ' ' '\n'));
    countTags=$(echo ${#tags[@]});
    if [ $countTags > $KEEP_NUMBER ]; then
        for i in `seq 1 $KEEP_NUMBER`; do
            unset "tags[${#tags[@]}-1]";
        done

        for tag in ${tags[@]}; do
            echo $(deleteTags $repoName $tag &);
        done
        wait
    fi
}

# DELETE IMAGE BY DIGEST
function deleteImage {
    repoName="$1"
    digest="$2"
    url=$BASE_URL/$repoName/manifests/$digest
    url=${url%$'\r'}

    echo $(curlExec "DELETE" "$url");
}

# GET DIGEST FOR TAG AND DELETE IT
function deleteTags {
    repoName="$1"
    tag="$2"

    digest=$(getDigest $repoName $tag)
    echo $(deleteImage $repoName $digest &);
}

# GETTING ALL REPOSITORIES
REPOSITORIES=$(getRepositories | jq -r '.repositories[]');

for repoName in $REPOSITORIES; do
    repositoryCleanup &
done
wait

echo 'Done';
