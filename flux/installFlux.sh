##
# Install Flux
##
##




# Helm install flux
helm upgrade --install flux \
fluxcd/flux --version 1.3.0 \
-f values/flux.yaml \
-n flux
