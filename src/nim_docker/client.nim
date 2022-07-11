import ./types
import httpClient
import jsony
import libcurl
import strutils, strformat
import re

proc initDocker*(baseUrl: string): Docker =
    result.client = newHttpClient()
    result.baseUrl = baseUrl
    result.version = "v1.41"

# can swap this to puppy if puppy supported sockets
proc request*(
            docker: Docker,
            path: string,
            httpMethod: HttpMethod,
            body: string,
            multipartData: MultipartData,
            useCurl: bool = false,
            headers: HttpHeaders = newHttpHeaders({"Accept": "application/json",
                "Content-Type": "application/json"})
        ): string =
    # a wrapper to choose between curl and inbult nim request
    # this is needed because nim request doesn't support http://unix:// or unix://

        let useUnix = docker.baseUrl.startsWith("unix://")
        if useCurl or useUnix:
            let webData: ref string = new string
            # /var/run/docker.sock
            let socketPath = docker.baseUrl[7..docker.baseUrl.high]
            let curl = easy_init()
            # function for curl to handle the data returned
            proc curlWriteFn(
                    buffer: cstring,
                    size: int,
                    count: int,
                    outstream: pointer
                ): int =
                let outbuf = cast[ref string](outstream)
                outbuf[] &= buffer
                result = size * count
                echo buffer
            # memory to hold returned data

            # use unix if unix Sock is specified else use http
            if useUnix:
                # /var/run/docker.sock
                discard curl.easy_setopt(OPT_UNIX_SOCKET_PATH,
                        socketPath.cstring)
                # v1.41/containers/json?all=1
                discard curl.easy_setopt(OPT_URL, path.cstring)
            else:
                # http://localhost:2375/v1.41/containers/json?all=1
                discard curl.easy_setopt(OPT_URL, (docker.baseUrl & "/" & path).cstring)


            discard curl.easy_setopt(OPT_CUSTOMREQUEST, ($httpMethod).cstring)
            discard curl.easy_setopt(OPT_POSTFIELDSIZE, body.len)
            discard curl.easy_setopt(OPT_POSTFIELDS, body)

            var headerChunk: Pslist
            headerChunk = headerChunk.slist_append("Accept: application/json")
            headerChunk = headerChunk.slist_append("Content-Type: application/json")
            discard curl.easy_setopt(OPT_HTTPHEADER, headerChunk);


            discard curl.easy_setopt(OPT_WRITEDATA, webData)
            discard curl.easy_setopt(OPT_WRITEFUNCTION, curlWriteFn)
            discard curl.easy_setopt(OPT_VERBOSE, 1)
            let ret = curl.easy_perform()

            if ret != E_OK:
                raise newException(Defect, $ret & $easy_strerror(ret))

            result = webData[]
            curl.easy_reset()

        else:
            # echo path
            # http://127.0.0.1:2375/ + . containers/json
            let httpURL = docker.baseUrl & "/" & path
            docker.client.headers = newHttpHeaders({
                "Accept": "application/json",
                "Content-Type": "application/json"})
            let res = docker.client.request(httpURL, httpMethod, body, headers, multipartData)
            case res.code:
            of Http200:
                result = res.body
            of Http400:
                raise newException(BadRequest, res.body)
            of Http500:
                raise newException(ServerError, res.body)
            else:
                raise newException(DockerError, res.body)

proc containers*(docker: Docker, all: bool = false): seq[Container] =
    let httpPath = "/containers/json" & (if all: "?all=true" else: "")
    let httpUrl = docker.version & httpPath
    let res = docker.request(httpUrl, HttpGet, "", nil)
    res.fromJson(seq[Container])

proc containerCreate*(
            docker: Docker,
            name: string,
            config: ContainerConfig
        ): CreateResponse =

    if not name.match(re"^/?[a-zA-Z0-9][a-zA-Z0-9_.-]+$"):
        raise newException(Defect, "Invalid container name, name must match ^/?[a-zA-Z0-9][a-zA-Z0-9_.-]+$")

    let httpPath = "/containers/create"
    let httpUrl = docker.version & httpPath & "?name=" & name
    let res = docker.request(httpUrl, HttpMethod.HttpPost, config.toJson(), nil, false)
    res.fromJson(CreateResponse)

proc containerStart*(
            docker: Docker,
            id: string, # name or id
            options = ContainerStartOptions(detatchKeys: "ctrl-c")
        ): string =
    let httpPath = "/containers/" & id & "/start"
    let httpUrl = docker.version & httpPath
    let res = docker.request(
            httpUrl,
            HttpMethod.HttpPost,
            # options.toJson(),
            "",
            nil,
            false
        )
    res

proc containerStop*(
            docker: Docker,
            id: string, # name or id
            options = ContainerStopOptions(t: 10)
        ): string =
    let httpPath = "/containers/" & id & "/stop"
    let httpUrl = docker.version & httpPath
    let res = docker.request(
            httpUrl,
            HttpMethod.HttpPost,
            options.toJson(),
            nil,
            false)
    res

proc containerRestart*(
            docker: Docker,
            id: string, # name or id
            options = ContainerStopOptions(t: 10)
        ): string =
    let httpPath = "/containers/" & id & "/restart"
    let httpUrl = docker.version & httpPath
    let res = docker.request(
            httpUrl, HttpMethod.HttpPost,
            options.toJson(),
            nil,
            false
        )
    res

# TODO oupdate, rename, pause, unpause, attatch, attatch via websocket, wait ...

proc containerRemove*(
            docker: Docker,
            id: string, # name or id
            options =  ContainerRemoveOptions(v: true, force: true, link: true)
        ): string =
    let httpPath = "/containers/" & id
    let httpUrl = docker.version & httpPath
    echo options.toJson()
    let res = docker.request(
            httpUrl,
            HttpMethod.HttpDelete,
            options.toJson(),
            nil,
            false
        )
    res

# this is a stream need to change it to a stream
proc containerStats*(
            docker: Docker,
            id: string, # name or id
            options = ContainerStatsOptions(stream: true)
        ): string =
    let httpPath = "/containers/" & id & "/stats"
    let httpUrl = docker.version & httpPath
    let res = docker.request(
            httpUrl,
            HttpMethod.HttpGet,
            options.toJson(),
            nil,
            false
        )
    res