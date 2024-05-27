#!/bin/bash

ytt -f templates \
  -v SESSION_NAMESPACE=$SESSION_NAMESPACE \
  -v INGRESS_DOMAIN=$INGRESS_DOMAIN \
  -v POLICY_ENGINE=$POLICY_ENGINE \
  --output-files exercises