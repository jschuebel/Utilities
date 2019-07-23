#docker command to build image with name jim:v1
#docker build -t ssscorewebapi:v1 .   --buld image in current directory
#docker build -t sssvr2016 .   --buld image in current directory
   
#docker command to run named container
#docker run -dit -p 5000:80 --name sssc ssscorewebapi:v1
#docker run -dit -p 5000:80 --name sssc  sssvr2016

# Build runtime image
FROM mcr.microsoft.com/windows/servercore:ltsc2016

MAINTAINER Jim Schuebel <schuebelsoft@yahoo.com>
WORKDIR /app
SHELL ["powershell", "-command"]

COPY SSSCalApp/SSSCalAppAPI/SSSCalAppWebAPI/bin/Debug/netcoreapp2.1/publish .

# Expose ports
EXPOSE 5000
#ENV ASPNETCORE_URLS http://*:5000
#HEALTHCHECK --interval=30s --timeout=3s --retries=1 CMD curl --silent --fail http://localhost:5000/hc || exit 1

# Start
ENTRYPOINT ["dotnet", "SSSCalAppWebAPI.dll"]
