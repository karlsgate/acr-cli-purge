FROM alpine:latest

ENV ACR_CLI_VERSION=0.11

RUN groupadd -r acruser && useradd -r -g acruser acruser

WORKDIR /home/acruser
RUN chown acruser:acruser /home/acruser

RUN echo "Installing acr-cli version $ACR_CLI_VERSION" \
    && mkdir -p /tmp/acr-cli \
    && wget -O /tmp/acr-cli/acr-cli_${ACR_CLI_VERSION}_Linux_x86_64.tar.gz https://github.com/Azure/acr-cli/releases/download/v${ACR_CLI_VERSION}/acr-cli_${ACR_CLI_VERSION}_Linux_x86_64.tar.gz \
    && tar -xvf /tmp/acr-cli/acr-cli_${ACR_CLI_VERSION}_Linux_x86_64.tar.gz -C /tmp/acr-cli \
    && mv /tmp/acr-cli/acr-cli /tmp/acr-cli/acr && chmod +x /tmp/acr-cli/acr \
    && mv /tmp/acr-cli/acr /usr/local/bin/ \
    && rm -rf /tmp/acr-cli/

COPY entrypoint.sh /home/acruser/entrypoint.sh
RUN chmod +x /home/acruser/entrypoint.sh \
    && chown acruser:acruser /home/acruser/entrypoint.sh

USER acruser

ENTRYPOINT ["/home/acruser/entrypoint.sh"]
