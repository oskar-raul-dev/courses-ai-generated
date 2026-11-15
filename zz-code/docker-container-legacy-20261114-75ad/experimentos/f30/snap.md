# Troubleshooting snapshot

- UTC: 2026-11-14T23:36:21Z
- Container: `legacy-node-dev`


## Docker client/server


```text
$ docker version
Client:
 Version:           29.9.3
 API version:       1.56
 Go version:        go1.26.10
 Git commit:        5457199
 Built:             Tue Nov  3 21:41:57 2026
 OS/Arch:           darwin/arm64
 Context:           desktop-linux

Server: Docker Desktop 4.99.0 (245822)
 Engine:
  Version:          29.9.3
  API version:      1.56 (minimum version 1.40)
  Go version:       go1.26.10
  Git commit:       70efc0e
  Built:            Tue Nov  3 21:41:25 2026
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          v2.4.2
  GitCommit:        b7a25261e029d68978bbf290df0a62fc819b3c51
 runc:
  Version:          1.5.2
  GitCommit:        v1.5.2-0-g29dd3dc2
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

## Docker context


```text
$ docker context show
desktop-linux
```

```text
$ docker context ls
NAME              DESCRIPTION                               DOCKER ENDPOINT                               ERROR
default           Current DOCKER_HOST based configuration   unix:///var/run/docker.sock                   
desktop-linux *   Docker Desktop                            unix:///Users/oskar/.docker/run/docker.sock   
```

## Docker info


```text
$ docker info
Client:
 Version:    29.9.3
 Context:    desktop-linux
 Debug Mode: false
 Plugins:
  agent: Docker AI Agent Runner (Docker Inc.)
    Version:  v1.153.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-agent
  ai: Docker AI Agent - Ask Gordon (Docker Inc.)
    Version:  v1.33.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-ai
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.38.1
    Path:     /Users/oskar/.docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v5.7.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-compose
  debug: Get a shell into any image or container (Docker Inc.)
    Version:  0.49.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-debug
  desktop: Docker Desktop commands (Docker Inc.)
    Version:  4.99.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-desktop
  dhi: CLI for managing Docker Hardened Images (Docker Inc.)
    Version:  v0.0.10
    Path:     /Users/oskar/.docker/cli-plugins/docker-dhi
  extension: Manages Docker extensions (Docker Inc.)
    Version:  v0.2.32
    Path:     /Users/oskar/.docker/cli-plugins/docker-extension
  init: Creates Docker-related starter files for your project (Docker Inc.)
    Version:  v1.4.1
    Path:     /Users/oskar/.docker/cli-plugins/docker-init
  mcp: Docker MCP Plugin (Docker Inc.)
    Version:  v0.44.3
    Path:     /Users/oskar/.docker/cli-plugins/docker-mcp
  model: Docker Model Runner (Docker Inc.)
    Version:  v1.2.9
    Path:     /Users/oskar/.docker/cli-plugins/docker-model
  offload: Docker Offload (Docker Inc.)
    Version:  v0.7.36
    Path:     /Users/oskar/.docker/cli-plugins/docker-offload
  pass: Docker Pass Secrets Manager Plugin (beta) (Docker Inc.)
    Version:  v0.3.2
    Path:     /Users/oskar/.docker/cli-plugins/docker-pass
  sandbox: "docker sandbox" is deprecated, use Docker Sandboxes instead (Docker Inc.)
    Version:  v0.13.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-sandbox
  scout: Docker Scout (Docker Inc.)
    Version:  v1.28.0
    Path:     /Users/oskar/.docker/cli-plugins/docker-scout

Server:
 Containers: 17
  Running: 3
  Paused: 0
  Stopped: 14
 Images: 307
 Server Version: 29.9.3
 Storage Driver: overlayfs
  driver-type: io.containerd.snapshotter.v1
 Logging Driver: local
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 CDI spec directories:
  /etc/cdi
  /var/run/cdi
 Discovered Devices:
  cdi: docker.com/gpu=webgpu
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: b7a25261e029d68978bbf290df0a62fc819b3c51
 runc version: v1.5.2-0-g29dd3dc2
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 7.0.14-linuxkit
 Operating System: Docker Desktop
 OSType: linux
 Architecture: aarch64
 CPUs: 8
 Total Memory: 7.819GiB
 Name: docker-desktop
 ID: 87266c26-a5c6-40ba-93d8-3fe66723f8c1
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 HTTP Proxy: http.docker.internal:3128
 HTTPS Proxy: http.docker.internal:3128
 No Proxy: hubproxy.docker.internal
 Labels:
  com.docker.desktop.address=unix:///Users/oskar/Library/Containers/com.docker.docker/Data/docker-cli.sock
 Experimental: false
 Insecure Registries:
  hubproxy.docker.internal:5555
  127.0.0.0/8
  ::1/128
 Live Restore Enabled: false
 Firewall Backend: iptables

```

## Container list


```text
$ docker ps -a --no-trunc
CONTAINER ID                                                       IMAGE                                                                                                                           COMMAND                                                       CREATED          STATUS                     PORTS                       NAMES
2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547   legacy-node-toolchain:phase15                                                                                                   "/usr/local/bin/docker-entrypoint.sh sleep infinity"          26 seconds ago   Up 26 seconds                                          legacy-node-dev
5b58c4b509659eb806000e233caca4d85c36296b5421850045b085d42ac055af   registry:2                                                                                                                      "/entrypoint.sh /etc/docker/registry/config.yml"              17 minutes ago   Up 17 minutes              127.0.0.1:15000->5000/tcp   p5-registry-local
39dd8af3dfd9aa33142a6b815adc91c1e4ecb05d668eceeb887747feb969542c   greenmail/standalone:2.1.15@sha256:309ba544ea482e5d4265d09921cdab07c8dad2cc4481d715c9b8ff5d3f0a149f                             "/home/greenmail/run_greenmail.sh"                            4 hours ago      Exited (143) 3 hours ago                               php-refresh-imap-1
60e93d2cca20a5fdbb2a194ef0e081c972297e39ef60e56f22a307fb502fdc9b   osixia/openldap:1.5.0@sha256:18742e9c449c9c1afe129d3f2f3ee15fb34cc43e5f940a20f3399728f41d7c28                                   "/container/tool/run"                                         4 hours ago      Exited (0) 3 hours ago                                 php-refresh-openldap-1
1339ddc8e24f0ff49a035f80f6a736120eafb9ca426eb5d3a92fc2d81bb9e026   delfer/alpine-ftp-server:latest@sha256:b27013e7436cea343826ba7edb77aa3a8b2d22df14e366b82d10a3b0b5ecc880                         "/sbin/tini -- /bin/start_vsftpd.sh"                          4 hours ago      Exited (0) 3 hours ago                                 php-refresh-ftp-1
65887e3643036871bd642d00485eb4ac84c510ebf1bb4a9047a169c4eb5d7500   linuxserver/openssh-server:10.3_p1-r2-ls243@sha256:161e0b670b31d9539ca1718bc5943e981779331b4e1c9d32e8929d7652a1f22f             "/init"                                                       4 hours ago      Exited (137) 3 hours ago                               php-refresh-sftp-1
41209b8d223ac8b6ff1ab282991060aa7fc4b765cb0a3a61f7fa196705e2e15e   postgres:18.7@sha256:9f4fd4aa918f52ae3d6f3b687f1de90d8f867cd4d520021545a9a50c120eae3b                                           "docker-entrypoint.sh postgres"                               29 hours ago     Exited (0) 3 hours ago                                 php-refresh-postgres-1
1d3bd5bf70581b93b8cccf240a9624b39a5d3c4b932a3104236d9ee0d7e314f1   redis:8.8.4@sha256:6e61ab45b3e867bacbef2fdd969ec74f4e0f8aaca8cc946cb8ac0c494035e7e7                                             "docker-entrypoint.sh redis-server"                           29 hours ago     Exited (0) 3 hours ago                                 php-refresh-redis-1
0bac1e642034bf2376e4e01f7f3da3e40164019aae9f5386f3623967eae37e36   mysql:9.7.4@sha256:df90258da46f6e7ff8574ff84f17618aba0765cac749928299c69fd4e7cb8ad8                                             "docker-entrypoint.sh mysqld"                                 29 hours ago     Exited (0) 3 hours ago                                 php-refresh-mysql-1
ed981c8eba39ff388a368dafd35773c26d10d650746cde74fd41f778749d1a52   axllent/mailpit:v1.33.1@sha256:aef2aacc11f075ec0fb6874275ee4a421e688e11a96ebb296134d1735c7761ce                                 "/mailpit"                                                    29 hours ago     Exited (0) 3 hours ago                                 php-refresh-mailpit-1
c9f1b6757fab24dd0e7f2af86279ee93c57f01de5a5b01a94e3977060e014a5a   gvenzl/oracle-free:23.26.3-slim-faststart@sha256:f5ff19033860d662c821cb04eb10483fa94f14f78eae252d054291ea07028093               "container-entrypoint.sh"                                     29 hours ago     Exited (143) 3 hours ago                               php-refresh-oracle-1
aa43fbd36edff38a7fe3fde8eb323374fbd0778baeb14cee3d6336c973f1b962   mcr.microsoft.com/mssql/server:2025-CU11-ubuntu-24.04@sha256:05644dad1266ca3d445d1e8f6d2ebb9a6a03df9a39376e0f7b48917356dca9d9   "/opt/mssql/bin/launch_sqlservr.sh /opt/mssql/bin/sqlservr"   29 hours ago     Exited (137) 3 hours ago                               php-refresh-sqlserver-1
8ce56825e4f771fc8f36454a548a50af0a6b77388150722bc611be5f5fe3737c   mysql:8.4.3                                                                                                                     "docker-entrypoint.sh mysqld"                                 3 days ago       Exited (0) 32 hours ago                                kotlin-learning-mysql-mysql-1
4cd482b1b11c6d9b32a35f7ae5b4cf3e3b747f09061cb6b43a168bfa28608e8b   postgres:17.2                                                                                                                   "docker-entrypoint.sh postgres"                               3 days ago       Exited (0) 32 hours ago                                kotlin-learning-postgres-postgres-1
e353ac23c1db366af455955a70438c9bcb4a50767da08f9d443f92f13a3c9937   postgres:17.11                                                                                                                  "docker-entrypoint.sh postgres"                               3 weeks ago      Exited (0) 3 weeks ago                                 gfapp-dev-db-1
7c605a031ec8faf1a4ef75ecdb37eb73949293a4844bc65f59b77d8c6dde3882   mdm-lab:p8                                                                                                                      "sleep infinity"                                              6 weeks ago      Exited (137) 5 weeks ago                               mdm-lab
```

## Container inspect


```text
$ docker inspect legacy-node-dev
[
    {
        "Id": "2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547",
        "Created": "2026-11-14T23:35:56.275976087Z",
        "Path": "/usr/local/bin/docker-entrypoint.sh",
        "Args": [
            "sleep",
            "infinity"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 19822,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2026-11-14T23:35:56.335903754Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:035c5f9ba87909e9395c3ca1b63f654cefd40d5b18ae2e7e62dc1a167fcfa78d",
        "ResolvConfPath": "/var/lib/docker/containers/2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547/hostname",
        "HostsPath": "/var/lib/docker/containers/2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547/hosts",
        "LogPath": "",
        "Name": "/legacy-node-dev",
        "RestartCount": 0,
        "Driver": "overlayfs",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "local",
                "Config": {}
            },
            "NetworkMode": "bridge",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                0,
                0
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": null,
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": [],
            "BlkioDeviceWriteBps": [],
            "BlkioDeviceReadIOps": [],
            "BlkioDeviceWriteIOps": [],
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/acpi",
                "/proc/asound",
                "/proc/interrupts",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/sys/devices/virtual/powercap",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "Storage": {
            "RootFS": {
                "Snapshot": {
                    "Name": "overlayfs"
                }
            }
        },
        "Mounts": [],
        "Config": {
            "Hostname": "2f33d140c2e6",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "NODE_VERSION=10.24.1",
                "API_TOKEN=<redacted>",
                "DB_PASSWORD=<redacted>",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "SHELL=<redacted>"
            ],
            "Cmd": [
                "sleep",
                "infinity"
            ],
            "Image": "legacy-node-toolchain:phase15",
            "Volumes": null,
            "WorkingDir": "/workspace",
            "Entrypoint": [
                "/usr/local/bin/docker-entrypoint.sh"
            ],
            "Labels": {
                "org.opencontainers.image.description": "Toolchain de desarrollo para proyectos Node.js legacy",
                "org.opencontainers.image.title": "legacy-node-toolchain"
            }
        },
        "NetworkSettings": {
            "SandboxID": "2c81ecc7c7f847a9c6591369c55455b16129f3e2e61646b63776a9fb0e949892",
            "SandboxKey": "/var/run/docker/netns/2c81ecc7c7f8",
            "Ports": {},
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "DriverOpts": null,
                    "GwPriority": 0,
                    "NetworkID": "5da2d36e0878a476ac51ad82f89443fdceb79029efa1da182285d1cdabda56c8",
                    "EndpointID": "3d2a6021126ed95ef3af8c850ebdef9c1d4613bdf03a7edf71659183a74b4e91",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "MacAddress": "be:b5:aa:9a:95:da",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "DNSNames": null
                }
            }
        },
        "ImageManifestDescriptor": {
            "mediaType": "application/vnd.oci.image.manifest.v1+json",
            "digest": "sha256:8924b24fd371fe385271b1991f1e2279537f0cfedeed1b0eac1fdff4d840bff3",
            "size": 2004,
            "platform": {
                "architecture": "amd64",
                "os": "linux"
            }
        }
    }
]
```

## Container state


```text
$ docker inspect --format status={{.State.Status}} running={{.State.Running}} exit={{.State.ExitCode}} oom={{.State.OOMKilled}} error={{printf "%q" .State.Error}} started={{.State.StartedAt}} finished={{.State.FinishedAt}} legacy-node-dev
status=running running=true exit=0 oom=false error="" started=2026-11-14T23:35:56.335903754Z finished=0001-01-01T00:00:00Z
```

## Mounts


```text
$ docker inspect --format {{json .Mounts}} legacy-node-dev
[]
```

## Network settings


```text
$ docker inspect --format {{json .NetworkSettings}} legacy-node-dev
{"SandboxID":"2c81ecc7c7f847a9c6591369c55455b16129f3e2e61646b63776a9fb0e949892","SandboxKey":"/var/run/docker/netns/2c81ecc7c7f8","Ports":{},"Networks":{"bridge":{"IPAMConfig":null,"Links":null,"Aliases":null,"DriverOpts":null,"GwPriority":0,"NetworkID":"5da2d36e0878a476ac51ad82f89443fdceb79029efa1da182285d1cdabda56c8","EndpointID":"3d2a6021126ed95ef3af8c850ebdef9c1d4613bdf03a7edf71659183a74b4e91","Gateway":"172.17.0.1","IPAddress":"172.17.0.2","MacAddress":"be:b5:aa:9a:95:da","IPPrefixLen":16,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"DNSNames":null}}}
```

## Recent logs


```text
$ docker logs --timestamps --tail 300 legacy-node-dev
2026-11-14T23:35:56.452359754Z legacy-node-toolchain: Node 10.24.1
```

## Processes


```text
$ docker top legacy-node-dev
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                19822               19797               0                   23:35               ?                   00:00:00            /run/rosetta/rosetta /bin/sleep sleep infinity
```

## Stats


```text
$ docker stats --no-stream legacy-node-dev
CONTAINER ID   NAME              CPU %     MEM USAGE / LIMIT     MEM %     NET I/O       BLOCK I/O    PIDS
2f33d140c2e6   legacy-node-dev   0.00%     3.504MiB / 7.819GiB   0.04%     998B / 126B   492kB / 0B   1
```

## Runtime identity


```text
$ docker exec legacy-node-dev sh -lc id; uname -a; cat /etc/os-release
uid=0(root) gid=0(root) groups=0(root)
Linux 2f33d140c2e6 7.0.14-linuxkit #1 SMP PREEMPT Fri Oct 30 13:45:20 UTC 2026 x86_64 GNU/Linux
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
NAME="Debian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

## Node


```text
$ docker exec legacy-node-dev sh -lc command -v node; node --version; command -v npm; npm --version; node -p "process.platform"; node -p "process.arch"; node -p "process.versions.modules"
/usr/local/bin/node
v10.24.1
/usr/local/bin/npm
6.14.12
linux
x64
64
```

## Python and toolchain


```text
$ docker exec legacy-node-dev sh -lc python2 --version 2>&1; python3 --version 2>&1; gcc --version | head -1; g++ --version | head -1; make --version | head -1
Python 2.7.16
Python 3.7.3
gcc (Debian 8.3.0-6) 8.3.0
g++ (Debian 8.3.0-6) 8.3.0
GNU Make 4.2.1
```

## Filesystem


```text
$ docker exec legacy-node-dev sh -lc pwd; df -h; df -i; mount | head -100
/workspace
Filesystem      Size  Used Avail Use% Mounted on
overlay        1007G  122G  834G  13% /
tmpfs            64M     0   64M   0% /dev
shm              64M     0   64M   0% /dev/shm
/dev/vda1      1007G  122G  834G  13% /etc/hosts
tmpfs           4.0K     0  4.0K   0% /proc/scsi
Filesystem       Inodes   IUsed    IFree IUse% Mounted on
overlay        67108864 2982126 64126738    5% /
tmpfs           1024786      16  1024770    1% /dev
shm             1024786       1  1024785    1% /dev/shm
/dev/vda1      67108864 2982126 64126738    5% /etc/hosts
tmpfs                 1       1        0  100% /proc/scsi
overlay on / type overlay (rw,relatime,lowerdir=/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/41963/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40686/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40685/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40684/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40683/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40682/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40681/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40680/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40374/fs:/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/40310/fs,upperdir=/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/41964/fs,workdir=/var/lib/desktop-containerd/daemon/io.containerd.snapshotter.v1.overlayfs/snapshots/41964/work,nouserxattr)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev type tmpfs (rw,nosuid,size=65536k,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=666)
sysfs on /sys type sysfs (ro,nosuid,nodev,noexec,relatime)
cgroup on /sys/fs/cgroup type cgroup2 (ro,nosuid,nodev,noexec,relatime)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
shm on /dev/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,size=65536k)
/dev/vda1 on /etc/hostname type ext4 (rw,relatime,discard,noauto_da_alloc)
/dev/vda1 on /etc/hosts type ext4 (rw,relatime,discard,noauto_da_alloc)
/dev/vda1 on /etc/resolv.conf type ext4 (rw,relatime,discard,noauto_da_alloc)
proc on /proc/bus type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/fs type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/irq type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sys type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sysrq-trigger type proc (ro,nosuid,nodev,noexec,relatime)
tmpfs on /proc/interrupts type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /proc/kcore type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /proc/keys type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /proc/scsi type tmpfs (ro,relatime,size=4k,nr_inodes=1)
tmpfs on /proc/timer_list type tmpfs (rw,nosuid,size=65536k,mode=755)
tmpfs on /sys/firmware type tmpfs (ro,relatime,size=4k,nr_inodes=1)
```

## Environment names


```text
$ docker exec legacy-node-dev sh -lc env | sed -E "s/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/\"\1=\2\"/" | sort
"API_TOKEN=<redacted>"
"DB_PASSWORD=<redacted>"
"HOME=/root"
"HOSTNAME=2f33d140c2e6"
"NODE_VERSION=10.24.1"
"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
"PWD=/workspace"
"SHELL=<redacted>"
```

## Listening sockets


```text
$ docker exec legacy-node-dev sh -lc command -v ss >/dev/null && ss -lntup || true
Netid   State   Recv-Q   Send-Q     Local Address:Port      Peer Address:Port   
```

## Recent Docker events


```text
$ docker events --since 10m --until 2026-11-14T23:36:28Z --filter container=legacy-node-dev
2026-11-14T18:35:56.318152004-05:00 container create 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:35:56.405141670-05:00 container start 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:01.692005006-05:00 container top 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:22.569447794-05:00 container top 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:23.686755919-05:00 container exec_create: sh -lc id; uname -a; cat /etc/os-release 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=62d99ba34724ded93d252b14ff7a856482a410f24483516d2834c7ab708f74b1, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:23.688837503-05:00 container exec_start: sh -lc id; uname -a; cat /etc/os-release 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=62d99ba34724ded93d252b14ff7a856482a410f24483516d2834c7ab708f74b1, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:23.819355336-05:00 container exec_die 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=62d99ba34724ded93d252b14ff7a856482a410f24483516d2834c7ab708f74b1, exitCode=0, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:23.843237794-05:00 container exec_create: sh -lc command -v node; node --version; command -v npm; npm --version; node -p "process.platform"; node -p "process.arch"; node -p "process.versions.modules" 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=f11d80d8611225d602a26d09757d827ebec0007dc7916a7bb43b97e69ddd0471, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:23.844973836-05:00 container exec_start: sh -lc command -v node; node --version; command -v npm; npm --version; node -p "process.platform"; node -p "process.arch"; node -p "process.versions.modules" 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=f11d80d8611225d602a26d09757d827ebec0007dc7916a7bb43b97e69ddd0471, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.514181171-05:00 container exec_die 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=f11d80d8611225d602a26d09757d827ebec0007dc7916a7bb43b97e69ddd0471, exitCode=0, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.552451671-05:00 container exec_create: sh -lc python2 --version 2>&1; python3 --version 2>&1; gcc --version | head -1; g++ --version | head -1; make --version | head -1 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=f44da0f52f3b18b01dc4eac25d62a5de092aa266ff88ec2edbdf247b6c4f4e10, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.554940046-05:00 container exec_start: sh -lc python2 --version 2>&1; python3 --version 2>&1; gcc --version | head -1; g++ --version | head -1; make --version | head -1 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=f44da0f52f3b18b01dc4eac25d62a5de092aa266ff88ec2edbdf247b6c4f4e10, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.740431546-05:00 container exec_die 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=f44da0f52f3b18b01dc4eac25d62a5de092aa266ff88ec2edbdf247b6c4f4e10, exitCode=0, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.769230296-05:00 container exec_create: sh -lc pwd; df -h; df -i; mount | head -100 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=c0226a08743254e8dddbf5de9bf2358cd9be3d6a7ffa7e8536cc620f57508148, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.771063463-05:00 container exec_start: sh -lc pwd; df -h; df -i; mount | head -100 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=c0226a08743254e8dddbf5de9bf2358cd9be3d6a7ffa7e8536cc620f57508148, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.901416046-05:00 container exec_die 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=c0226a08743254e8dddbf5de9bf2358cd9be3d6a7ffa7e8536cc620f57508148, exitCode=0, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.938892171-05:00 container exec_create: sh -lc env | sed -E "s/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/\"\1=\2\"/" | sort 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=ecf5d998d42a8239f2060b041e234b9b89e286c908e809a57aff2020090109d7, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
2026-11-14T18:36:27.941392713-05:00 container exec_start: sh -lc env | sed -E "s/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/\"\1=\2\"/" | sort 2f33d140c2e69c43bc8595687d10d9dbfed737dd4df04860e373da96dabc2547 (desktop.docker.io/ports.scheme=v2, execID=ecf5d998d42a8239f2060b041e234b9b89e286c908e809a57aff2020090109d7, image=legacy-node-toolchain:phase15, name=legacy-node-dev, org.opencontainers.image.description=Toolchain de desarrollo para proyectos Node.js legacy, org.opencontainers.image.title=legacy-node-toolchain)
```

Snapshot terminado.
