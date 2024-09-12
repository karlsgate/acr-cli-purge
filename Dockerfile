FROM alpine:latest

ENV ACR_CLI_VERSION=0.11


RUN echo "Installing acr-cli version $ACR_CLI_VERSION" \
    && mkdir -p /tmp/acr-cli \
    && wget -O /tmp/acr-cli/acr-cli_${ACR_CLI_VERSION}_Linux_x86_64.tar.gz https://github.com/Azure/acr-cli/releases/download/v${ACR_CLI_VERSION}/acr-cli_${ACR_CLI_VERSION}_Linux_x86_64.tar.gz \
    && tar -xvf /tmp/acr-cli/acr-cli_${ACR_CLI_VERSION}_Linux_x86_64.tar.gz -C /tmp/acr-cli \
    && mv /tmp/acr-cli/acr-cli /tmp/acr-cli/acr && chmod +x /tmp/acr-cli/acr \
    && mv /tmp/acr-cli/acr /usr/local/bin/ \
    && rm -rf /tmp/acr-cli/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
