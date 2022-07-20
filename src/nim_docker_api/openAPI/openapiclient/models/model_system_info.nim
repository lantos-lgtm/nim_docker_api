#
# Docker Engine API
# 
# The Engine API is an HTTP API served by Docker Engine. It is the API the Docker client uses to communicate with the Engine, so everything the Docker client can do can be done with the API.  Most of the client's commands map directly to API endpoints (e.g. `docker ps` is `GET /containers/json`). The notable exception is running containers, which consists of several API calls.  # Errors  The API uses standard HTTP status codes to indicate the success or failure of the API call. The body of the response will be JSON in the following format:  ``` {   \"message\": \"page not found\" } ```  # Versioning  The API is usually changed in each release, so API calls are versioned to ensure that clients don't break. To lock to a specific version of the API, you prefix the URL with its version, for example, call `/v1.30/info` to use the v1.30 version of the `/info` endpoint. If the API version specified in the URL is not supported by the daemon, a HTTP `400 Bad Request` error message is returned.  If you omit the version-prefix, the current version of the API (v1.41) is used. For example, calling `/info` is the same as calling `/v1.41/info`. Using the API without a version-prefix is deprecated and will be removed in a future release.  Engine releases in the near future should support this version of the API, so your client will continue to work even if it is talking to a newer Engine.  The API uses an open schema model, which means server may add extra properties to responses. Likewise, the server will ignore any extra query parameters and request body properties. When you write clients, you need to ignore additional properties in responses to ensure they do not break when talking to newer daemons.   # Authentication  Authentication for registries is handled client side. The client has to send authentication details to various endpoints that need to communicate with registries, such as `POST /images/(name)/push`. These are sent as `X-Registry-Auth` header as a [base64url encoded](https://tools.ietf.org/html/rfc4648#section-5) (JSON) string with the following structure:  ``` {   \"username\": \"string\",   \"password\": \"string\",   \"email\": \"string\",   \"serveraddress\": \"string\" } ```  The `serveraddress` is a domain/IP without a protocol. Throughout this structure, double quotes are required.  If you have already got an identity token from the [`/auth` endpoint](#operation/SystemAuth), you can just pass this instead of credentials:  ``` {   \"identitytoken\": \"9cbaf023786cd7...\" } ``` 
# The version of the OpenAPI document: 1.41
# 
# Generated by: https://openapi-generator.tech
#

#import json
#import tables

import model_commit
import model_generic_resources_inner
#import model_map
import tables
import model_plugins_info
import model_registry_service_config
import model_runtime
import model_swarm_info
import model_system_info_default_address_pools_inner

# type CgroupDriver* {.pure.} = enum
#   Cgroupfs
#   Systemd
#   None

# type CgroupVersion* {.pure.} = enum
#   `1`
#   `2`

# type Isolation* {.pure.} = enum
#   Default
#   Hyperv
#   Process

type CgroupDriver* {.pure.} = enum
  Cgroupfs = "cgroupfs"
  Systemd = "systemd"
  None = "none"

type CgroupVersion* {.pure.} = enum
  `1` = "1"
  `2` = "2"

type Isolation* {.pure.} = enum
  Default = "default"
  Hyperv = "hyperv"
  Process = "process"

type SystemInfo* = object
  ## 
  ID*: string ## Unique identifier of the daemon.  <p><br /></p>  > **Note**: The format of the ID itself is not part of the API, and > should not be considered stable. 
  containers*: int ## Total number of containers on the host.
  containersRunning*: int ## Number of containers with status `\"running\"`. 
  containersPaused*: int ## Number of containers with status `\"paused\"`. 
  containersStopped*: int ## Number of containers with status `\"stopped\"`. 
  images*: int ## Total number of images on the host.  Both _tagged_ and _untagged_ (dangling) images are counted. 
  driver*: string ## Name of the storage driver in use.
  driverStatus*: seq[seq[string]] ## Information specific to the storage driver, provided as \"label\" / \"value\" pairs.  This information is provided by the storage driver, and formatted in a way consistent with the output of `docker info` on the command line.  <p><br /></p>  > **Note**: The information returned in this field, including the > formatting of values and labels, should not be considered stable, > and may change without notice. 
  dockerRootDir*: string ## Root directory of persistent Docker state.  Defaults to `/var/lib/docker` on Linux, and `C:\\ProgramData\\docker` on Windows. 
  plugins*: PluginsInfo
  memoryLimit*: bool ## Indicates if the host has memory limit support enabled.
  swapLimit*: bool ## Indicates if the host has memory swap limit support enabled.
  kernelMemory*: bool ## Indicates if the host has kernel memory limit support enabled.  <p><br /></p>  > **Deprecated**: This field is deprecated as the kernel 5.4 deprecated > `kmem.limit_in_bytes`. 
  kernelMemoryTCP*: bool ## Indicates if the host has kernel memory TCP limit support enabled.  Kernel memory TCP limits are not supported when using cgroups v2, which does not support the corresponding `memory.kmem.tcp.limit_in_bytes` cgroup. 
  cpuCfsPeriod*: bool ## Indicates if CPU CFS(Completely Fair Scheduler) period is supported by the host. 
  cpuCfsQuota*: bool ## Indicates if CPU CFS(Completely Fair Scheduler) quota is supported by the host. 
  cPUShares*: bool ## Indicates if CPU Shares limiting is supported by the host. 
  cPUSet*: bool ## Indicates if CPUsets (cpuset.cpus, cpuset.mems) are supported by the host.  See [cpuset(7)](https://www.kernel.org/doc/Documentation/cgroup-v1/cpusets.txt) 
  pidsLimit*: bool ## Indicates if the host kernel has PID limit support enabled.
  oomKillDisable*: bool ## Indicates if OOM killer disable is supported on the host.
  iPv4Forwarding*: bool ## Indicates IPv4 forwarding is enabled.
  bridgeNfIptables*: bool ## Indicates if `bridge-nf-call-iptables` is available on the host.
  bridgeNfIp6tables*: bool ## Indicates if `bridge-nf-call-ip6tables` is available on the host.
  debug*: bool ## Indicates if the daemon is running in debug-mode / with debug-level logging enabled. 
  nFd*: int ## The total number of file Descriptors in use by the daemon process.  This information is only returned if debug-mode is enabled. 
  nGoroutines*: int ## The  number of goroutines that currently exist.  This information is only returned if debug-mode is enabled. 
  systemTime*: string ## Current system-time in [RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds. 
  loggingDriver*: string ## The logging driver to use as a default for new containers. 
  cgroupDriver*: CgroupDriver ## The driver to use for managing cgroups. 
  cgroupVersion*: CgroupVersion ## The version of the cgroup. 
  nEventsListener*: int ## Number of event listeners subscribed.
  kernelVersion*: string ## Kernel version of the host.  On Linux, this information obtained from `uname`. On Windows this information is queried from the <kbd>HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\</kbd> registry value, for example _\"10.0 14393 (14393.1198.amd64fre.rs1_release_sec.170427-1353)\"_. 
  operatingSystem*: string ## Name of the host's operating system, for example: \"Ubuntu 16.04.2 LTS\" or \"Windows Server 2016 Datacenter\" 
  oSVersion*: string ## Version of the host's operating system  <p><br /></p>  > **Note**: The information returned in this field, including its > very existence, and the formatting of values, should not be considered > stable, and may change without notice. 
  oSType*: string ## Generic type of the operating system of the host, as returned by the Go runtime (`GOOS`).  Currently returned values are \"linux\" and \"windows\". A full list of possible values can be found in the [Go documentation](https://golang.org/doc/install/source#environment). 
  architecture*: string ## Hardware architecture of the host, as returned by the Go runtime (`GOARCH`).  A full list of possible values can be found in the [Go documentation](https://golang.org/doc/install/source#environment). 
  NCPU*: int ## The number of logical CPUs usable by the daemon.  The number of available CPUs is checked by querying the operating system when the daemon starts. Changes to operating system CPU allocation after the daemon is started are not reflected. 
  memTotal*: int64 ## Total amount of physical memory available on the host, in bytes. 
  indexServerAddress*: string ## Address / URL of the index server that is used for image search, and as a default for user authentication for Docker Hub and Docker Cloud. 
  registryConfig*: RegistryServiceConfig
  genericResources*: seq[GenericResources_inner] ## User-defined resources can be either Integer resources (e.g, `SSD=3`) or String resources (e.g, `GPU=UUID1`). 
  httpProxy*: string ## HTTP-proxy configured for the daemon. This value is obtained from the [`HTTP_PROXY`](https://www.gnu.org/software/wget/manual/html_node/Proxies.html) environment variable. Credentials ([user info component](https://tools.ietf.org/html/rfc3986#section-3.2.1)) in the proxy URL are masked in the API response.  Containers do not automatically inherit this configuration. 
  httpsProxy*: string ## HTTPS-proxy configured for the daemon. This value is obtained from the [`HTTPS_PROXY`](https://www.gnu.org/software/wget/manual/html_node/Proxies.html) environment variable. Credentials ([user info component](https://tools.ietf.org/html/rfc3986#section-3.2.1)) in the proxy URL are masked in the API response.  Containers do not automatically inherit this configuration. 
  noProxy*: string ## Comma-separated list of domain extensions for which no proxy should be used. This value is obtained from the [`NO_PROXY`](https://www.gnu.org/software/wget/manual/html_node/Proxies.html) environment variable.  Containers do not automatically inherit this configuration. 
  name*: string ## Hostname of the host.
  labels*: seq[string] ## User-defined labels (key/value metadata) as set on the daemon.  <p><br /></p>  > **Note**: When part of a Swarm, nodes can both have _daemon_ labels, > set through the daemon configuration, and _node_ labels, set from a > manager node in the Swarm. Node labels are not included in this > field. Node labels can be retrieved using the `/nodes/(id)` endpoint > on a manager node in the Swarm. 
  experimentalBuild*: bool ## Indicates if experimental features are enabled on the daemon. 
  serverVersion*: string ## Version string of the daemon.  > **Note**: the [standalone Swarm API](/swarm/swarm-api/) > returns the Swarm version instead of the daemon  version, for example > `swarm/1.2.8`. 
  clusterStore*: string ## URL of the distributed storage backend.   The storage backend is used for multihost networking (to store network and endpoint information) and by the node discovery mechanism.  <p><br /></p>  > **Deprecated**: This field is only propagated when using standalone Swarm > mode, and overlay networking using an external k/v store. Overlay > networks with Swarm mode enabled use the built-in raft store, and > this field will be empty. 
  clusterAdvertise*: string ## The network endpoint that the Engine advertises for the purpose of node discovery. ClusterAdvertise is a `host:port` combination on which the daemon is reachable by other hosts.  <p><br /></p>  > **Deprecated**: This field is only propagated when using standalone Swarm > mode, and overlay networking using an external k/v store. Overlay > networks with Swarm mode enabled use the built-in raft store, and > this field will be empty. 
  runtimes*: Table[string, Runtime] ## List of [OCI compliant](https://github.com/opencontainers/runtime-spec) runtimes configured on the daemon. Keys hold the \"name\" used to reference the runtime.  The Docker daemon relies on an OCI compliant runtime (invoked via the `containerd` daemon) as its interface to the Linux kernel namespaces, cgroups, and SELinux.  The default runtime is `runc`, and automatically configured. Additional runtimes can be configured by the user and will be listed here. 
  defaultRuntime*: string ## Name of the default OCI runtime that is used when starting containers.  The default can be overridden per-container at create time. 
  swarm*: SwarmInfo
  liveRestoreEnabled*: bool ## Indicates if live restore is enabled.  If enabled, containers are kept running when the daemon is shutdown or upon daemon start if running containers are detected. 
  isolation*: Isolation ## Represents the isolation technology to use as a default for containers. The supported values are platform-specific.  If no isolation value is specified on daemon start, on Windows client, the default is `hyperv`, and on Windows server, the default is `process`.  This option is currently not used on other platforms. 
  initBinary*: string ## Name and, optional, path of the `docker-init` binary.  If the path is omitted, the daemon searches the host's `$PATH` for the binary and uses the first result. 
  containerdCommit*: Commit
  runcCommit*: Commit
  initCommit*: Commit
  securityOptions*: seq[string] ## List of security features that are enabled on the daemon, such as apparmor, seccomp, SELinux, user-namespaces (userns), and rootless.  Additional configuration options for each security feature may be present, and are included as a comma-separated list of key/value pairs. 
  productLicense*: string ## Reports a summary of the product license on the daemon.  If a commercial license has been applied to the daemon, information such as number of nodes, and expiration are included. 
  defaultAddressPools*: seq[SystemInfo_DefaultAddressPools_inner] ## List of custom default address pools for local networks, which can be specified in the daemon.json file or dockerd option.  Example: a Base \"10.10.0.0/16\" with Size 24 will define the set of 256 10.10.[0-255].0/24 address pools. 
  warnings*: seq[string] ## List of warnings / informational messages about missing features, or issues related to the daemon configuration.  These messages can be printed by the client as information to the user. 

# func `%`*(v: CgroupDriver): JsonNode =
#   let str = case v:
#     of CgroupDriver.Cgroupfs: "cgroupfs"
#     of CgroupDriver.Systemd: "systemd"
#     of CgroupDriver.None: "none"

#   JsonNode(kind: JString, str: str)

# func `$`*(v: CgroupDriver): string =
#   result = case v:
#     of CgroupDriver.Cgroupfs: "cgroupfs"
#     of CgroupDriver.Systemd: "systemd"
#     of CgroupDriver.None: "none"

# func `%`*(v: CgroupVersion): JsonNode =
#   let str = case v:
#     of CgroupVersion.`1`: "1"
#     of CgroupVersion.`2`: "2"

#   JsonNode(kind: JString, str: str)

# func `$`*(v: CgroupVersion): string =
#   result = case v:
#     of CgroupVersion.`1`: "1"
#     of CgroupVersion.`2`: "2"

# func `%`*(v: Isolation): JsonNode =
#   let str = case v:
#     of Isolation.Default: "default"
#     of Isolation.Hyperv: "hyperv"
#     of Isolation.Process: "process"

#   JsonNode(kind: JString, str: str)

# func `$`*(v: Isolation): string =
#   result = case v:
#     of Isolation.Default: "default"
#     of Isolation.Hyperv: "hyperv"
#     of Isolation.Process: "process"
