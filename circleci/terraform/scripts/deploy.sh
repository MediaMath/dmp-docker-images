#! /bin/sh


set -e

# Verify that any one of an array of env variables is not empty
verify_not_empty() {
    for var in $@
    do
        env_val=$(eval "echo \$$var")
        if [ -z "${env_val}" ]
        then
            >&2 echo "Empty environment variable $var. Exiting..."
            exit 1
        fi
    done
}

source_env() {
    # verify if the following environment variables are not empty
    echo "Retrieving environment variables from ${WORK_DIR}/.circleci/env.sh..."
    source ${WORK_DIR}/.circleci/env.sh
}

predeploy() {
    source_env
    verify_not_empty ENVIRONMENT \
        HEATH_CLIENT_ID \
        HEATH_CLIENT_SECRET \
        APP_NAME \
        VERSION

    if [ -z ${CIRCLE_USERNAME} ]
    then
        CIRCLE_USERNAME=evilwire
    fi

    ENV_TYPE=non-prod
    if [ 'prod' = "${ENVIRONMENT}" ]
    then
        ENV_TYPE=prod
    fi

    echo "[DEBUG] CIRCLE_USERNAME=${CIRCLE_USERNAME}"
    echo "[DEBUG] HEATH_CLIENT_ID=${HEATH_CLIENT_ID}"
    echo "[DEBUG] APP_NAME=${APP_NAME}"
    echo "[DEBUG] VERSION=${VERSION}"
    echo "[DEBUG] CIRCLE_SHA1=${CIRCLE_SHA1}"
    echo "[DEBUG] CIRCLE_BRANCH=${CIRCLE_BRANCH}"
    echo "[DEBUG] ENV_TYPE=${ENV_TYPE}"

    HEATH_ID=`docker run \
            -e CIRCLE_USERNAME=${CIRCLE_USERNAME} \
            -e HEATH_CLIENT_ID=${HEATH_CLIENT_ID} \
            -e HEATH_CLIENT_SECRET=${HEATH_CLIENT_SECRET} \
        docker.mediamath.com/heath/heath-cli \
            pre-deploy \
            --serviceNames ${APP_NAME} \
            --version ${VERSION} \
            --gitSha ${CIRCLE_SHA1} \
            --branchName ${CIRCLE_BRANCH} \
            --environmentType ${ENV_TYPE}`

    echo "HEATH_ID=${HEATH_ID}"
    echo $HEATH_ID > .heathid
}

deploy() {
    source_env
    verify_not_empty HEATH_CLIENT_ID \
        HEATH_CLIENT_SECRET \
        WORK_DIR \
        ACCOUNT \
        REGION \
        ENVIRONMENT

    FAILED=0
    export REMOTE_STATE_BUCKET=octane-platform-tfstates
    export AWS_ACCOUNT_ID=${ACCOUNT}
    export AWS_REGION=${REGION}
    export REPO=${WORK_DIR}
    /terraform/entrypoint.sh deploy ${ENVIRONMENT} default || FAILED=1

    if [ ${FAILED} -eq 1 ]
    then
        echo "Deployment failed..."
        docker run \
                -e HEATH_CLIENT_ID=${HEATH_CLIENT_ID} \
                -e HEATH_CLIENT_SECRET=${HEATH_CLIENT_SECRET} \
            docker.mediamath.com/heath/heath-cli \
                fail \
                `cat .heathid` \
                --reason "terraform deploy failed"
        exit 1
    else
        echo "Deployment succeeded..."
        docker run \
                -e HEATH_CLIENT_ID=${HEATH_CLIENT_ID} \
                -e HEATH_CLIENT_SECRET=${HEATH_CLIENT_SECRET} \
            docker.mediamath.com/heath/heath-cli \
                post-deploy \
                `cat .heathid`
    fi
}

verify_deploy() {
    source_env
    verify_not_empty HEALTHCHECK_URL VERSION

    python3 ${SCRIPT_HOME}/wait.py \
        --url ${HEALTHCHECK_URL} \
        --version ${VERSION}
}

case $1 in

get-heath)
    echo "Getting heath-cli container from Artifactory..."
    verify_not_empty ARTIFACTORY_USERNAME ARTIFACTORY_PASSWORD
    docker login docker.mediamath.com -u ${ARTIFACTORY_USERNAME} --password ${ARTIFACTORY_PASSWORD}
    docker pull docker.mediamath.com/heath/heath-cli
;;

pre-deploy)
    echo "Registering pre-deployment info..."
    predeploy
;;

deploy)
    echo "Deploying to ${ENVIRONMENT} (subenv \"default\")..."
    deploy
;;

verify)
    echo "Checking that the stack is deployed correctly..."
    verify_deploy
;;

esac
