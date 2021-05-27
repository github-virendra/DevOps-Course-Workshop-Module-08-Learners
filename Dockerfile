# ARG REPO=mcr.microsoft.com/dotnet/runtime-deps
# FROM $REPO:3.1-buster-slim

# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#         curl \
#     && rm -rf /var/lib/apt/lists/*


  
# FROM amd64/buildpack-deps:buster-scm
# WORKDIR /app
# COPY . /app/
# ENV \
#     # Enable detection of running in a container
#     DOTNET_RUNNING_IN_CONTAINER=true \
#     # Enable correct mode for dotnet watch (only mode supported in a container)
#     DOTNET_USE_POLLING_FILE_WATCHER=true \
#     # Skip extraction of XML docs - generally not useful within an image/container - helps performance
#     NUGET_XMLDOC_MODE=skip \
#     # PowerShell telemetry for docker image usage
#     POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Debian-10

# # Install .NET CLI dependencies
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#         libc6 \
#         libgcc1 \
#         libgssapi-krb5-2 \
#         libicu63 \
#         libssl1.1 \
#         libstdc++6 \
#         zlib1g \
#     && rm -rf /var/lib/apt/lists/*

# # Install .NET Core SDK
# RUN dotnet_sdk_version=3.1.409 \
#     && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
#     && dotnet_sha512='63d24f1039f68abc46bf40a521f19720ca74a4d89a2b99d91dfd6216b43a81d74f672f74708efa6f6320058aa49bf13995638e3b8057efcfc84a2877527d56b6' \
#     && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
#     && mkdir -p /usr/share/dotnet \
#     && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
#     && rm dotnet.tar.gz \
#     && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
#     # Trigger first run experience by running arbitrary cmd
#     && dotnet help

# # Install PowerShell global tool
# RUN powershell_version=7.0.6 \
#     && curl -SL --output PowerShell.Linux.x64.$powershell_version.nupkg https://pwshtool.blob.core.windows.net/tool/$powershell_version/PowerShell.Linux.x64.$powershell_version.nupkg \
#     && powershell_sha512='adfeaf8d21aa3a97de708a97661950ca33f11c39b5a4c78c503ef8692c477f61d8523203566e3c281228bc37d01ee2bc39992486b8bc4ed0512adf9cf69f934a' \
#     && echo "$powershell_sha512  PowerShell.Linux.x64.$powershell_version.nupkg" | sha512sum -c - \
#     && mkdir -p /usr/share/powershell \
#     && dotnet tool install --add-source / --tool-path /usr/share/powershell --version $powershell_version PowerShell.Linux.x64 \
#     && dotnet nuget locals all --clear \
#     && rm PowerShell.Linux.x64.$powershell_version.nupkg \
#     && ln -s /usr/share/powershell/pwsh /usr/bin/pwsh \
#     && chmod 755 /usr/share/powershell/pwsh \
#     # To reduce image size, remove the copy nupkg that nuget keeps.
#     && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm

# # Install .NET Core
# RUN dotnet_version=3.1.15 \
#     && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$dotnet_version/dotnet-runtime-$dotnet_version-linux-x64.tar.gz \
#     && dotnet_sha512='0de999a51cdd53a2efa4ae3552834b540d59f598438675cb9b2ab1f16b41a64dbf0a25a2c8e65324bbdc594935046bc6ee32d8f8c25a95f607da2985f903ed55' \
#     && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
#     && mkdir -p /usr/share/dotnet \
#     && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
#     && rm dotnet.tar.gz \
#     && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

ARG REPO=mcr.microsoft.com/dotnet/aspnet
FROM $REPO:5.0-buster-slim-amd64
WORKDIR /app
COPY . /app/

ENV \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    DOTNET_SDK_VERSION=5.0.202 \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # PowerShell telemetry for docker image usage
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetSDK-Debian-10

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        git \
        procps \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='01ed59f236184987405673d24940d55ce29d830e7dbbc19556fdc03893039e6046712de6f901dc9911047a0dee4fd15319b7e94f8a31df6b981fa35bd93d9838' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz ./packs ./sdk ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
    && rm dotnet.tar.gz \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Install PowerShell global tool
RUN powershell_version=7.1.3 \
    && curl -SL --output PowerShell.Linux.x64.$powershell_version.nupkg https://pwshtool.blob.core.windows.net/tool/$powershell_version/PowerShell.Linux.x64.$powershell_version.nupkg \
    && powershell_sha512='537d885b79dd1cd183d14b5f5e71046558fb015f562bb817ee90fbabaa9b1039c822949b7e1a5c9b69a976eae09786e3b2c0f0586c01c822868cc48ea7e36620' \
    && echo "$powershell_sha512  PowerShell.Linux.x64.$powershell_version.nupkg" | sha512sum -c - \
    && mkdir -p /usr/share/powershell \
    && dotnet tool install --add-source / --tool-path /usr/share/powershell --version $powershell_version PowerShell.Linux.x64 \
    && dotnet nuget locals all --clear \
    && rm PowerShell.Linux.x64.$powershell_version.nupkg \
    && ln -s /usr/share/powershell/pwsh /usr/bin/pwsh \
    && chmod 755 /usr/share/powershell/pwsh \
    # To reduce image size, remove the copy nupkg that nuget keeps.
    && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm

# Using Debian, as root
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs
RUN dotnet build 