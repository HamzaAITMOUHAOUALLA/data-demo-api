#!/bin/bash
set -e

: "${IMAGE_NAME:?IMAGE_NAME not set}"
: "${IMAGE_TAG:?IMAGE_TAG not set}"
: "${HARBOR_REGISTRY:?HARBOR_REGISTRY not set}"
: "${HARBOR_PROJECT:?HARBOR_PROJECT not set}"
: "${HARBOR_USER:?HARBOR_USER not set}"
: "${HARBOR_PASS:?HARBOR_PASS not set}"

FULL_IMAGE="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Tagging image ${FULL_IMAGE}..."

docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}

echo "Logging into Harbor..."
echo "$HARBOR_PASS" | docker login ${HARBOR_REGISTRY} -u "$HARBOR_USER" --password-stdin

echo "Pushing ${IMAGE_TAG}..."
docker push ${FULL_IMAGE}

docker logout ${HARBOR_REGISTRY}

echo "Push to Harbor completed ✅"
