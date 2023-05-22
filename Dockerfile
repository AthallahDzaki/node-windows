ARG core=mcr.microsoft.com/windows/servercore:ltsc2019
ARG target=mcr.microsoft.com/windows/servercore:ltsc2019
FROM $core as download

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NODE_VERSION 12.18.3

RUN Invoke-WebRequest $('https://nodejs.org/dist/v{0}/node-v{0}-win-x64.zip' -f $env:NODE_VERSION) -OutFile 'node.zip' -UseBasicParsing ; \
    Expand-Archive node.zip -DestinationPath C:\ ; \
    Rename-Item -Path $('C:\node-v{0}-win-x64' -f $env:NODE_VERSION) -NewName 'C:\nodejs'

ENV GIT_VERSION 2.20.1
ENV GIT_DOWNLOAD_URL https://github.com/git-for-windows/git/releases/download/v${GIT_VERSION}.windows.1/MinGit-${GIT_VERSION}-busybox-64-bit.zip
ENV GIT_SHA256 9817ab455d9cbd0b09d8664b4afbe4bbf78d18b556b3541d09238501a749486c

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest -UseBasicParsing $env:GIT_DOWNLOAD_URL -OutFile git.zip; \
    if ((Get-FileHash git.zip -Algorithm sha256).Hash -ne $env:GIT_SHA256) {exit 1} ; \
    Expand-Archive git.zip -DestinationPath C:\git; \
    Remove-Item git.zip

FROM $target

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NPM_CONFIG_LOGLEVEL info

ENV VCTargetsPath="C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140"

COPY --from=download /nodejs /nodejs
COPY --from=download /git /git

RUN $env:PATH = 'C:\nodejs;C:\git\cmd;C:\git\mingw64\bin;C:\git\usr\bin;{0}' -f $env:PATH ; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)
    
RUN npm config set msbuild_path='C:\Program Files (x86)\MSBuild\14.0\Bin\amd64\msbuild.exe'

CMD [ "node.exe" ]
