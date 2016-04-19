#!/bin/bash

terraform remote config \
    -backend=s3 \
    -backend-config="bucket=nubis-deploy-ac492a79-5dfb-42fa-abc2-015a5cfc1281" \
    -backend-config="key=terraform/nubis-deploy" \
    -backend-config="region=eu-west-1"
