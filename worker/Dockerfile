FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0@sha256:f7e28a0a3f6f9235929ec19274fd0ddf8534e9159f99fac602ac73304f1ce99f AS build
ARG TARGETARCH
WORKDIR /source
COPY *.csproj ./
RUN dotnet restore -a $TARGETARCH
COPY . ./
RUN dotnet publish -c Release -o /app -a $TARGETARCH --no-restore --self-contained false
FROM mcr.microsoft.com/dotnet/runtime:8.0@sha256:60d11c2be381e7f90b8bd984472dd2432933858aba55087d5936980cf2071d5a
RUN apt-get update && apt-get install -y --no-install-recommends --only-upgrade perl-base && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build --chown=1654:1654 /app ./
USER 1654:1654
ENTRYPOINT ["dotnet", "Worker.dll"]
