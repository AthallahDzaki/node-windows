FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

RUN Invoke-WebRequest -OutFile nodejs.zip -UseBasicParsing "https://nodejs.org/dist/v12.4.0/node-v12.4.0-win-x64.zip"; Expand-Archive nodejs.zip -DestinationPath C:\; Rename-Item "C:\\node-v12.4.0-win-x64" c:\nodejs

WORKDIR C:/nodejs
COPY C:/nodejs/ .
RUN SETX PATH \"$Env:PATH;C:\nodejs\" /m
RUN npm config set registry https://registry.npmjs.org/
