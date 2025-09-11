# 本地部署 gitlab

> reference： [https://gitlab.cn/install/](https://gitlab.cn/install/)
>

文档中步骤走完后可能会报错：
```bash
Notes:
Default admin account has been configured with following details:
Username: root
Password: You didn't opt-in to print initial root password to STDOUT.
Password stored to /etc/gitlab/initial_root_password. This file will be cleaned up in first reconfigure run after 24 hours.

NOTE: Because these credentials might be present in your log files in plain text, it is highly recommended to reset the password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

[2025-09-04T15:20:25+00:00] FATAL: Stacktrace dumped to /opt/gitlab/embedded/cookbooks/cache/cinc-stacktrace.out
[2025-09-04T15:20:25+00:00] FATAL: ---------------------------------------------------------------------------------------
[2025-09-04T15:20:25+00:00] FATAL: PLEASE PROVIDE THE CONTENTS OF THE stacktrace.out FILE (above) IF YOU FILE A BUG REPORT
[2025-09-04T15:20:25+00:00] FATAL: ---------------------------------------------------------------------------------------
[2025-09-04T15:20:25+00:00] FATAL: RuntimeError: letsencrypt_certificate[gitlab.kris.com] (letsencrypt::http_authorization line 6) had an error: RuntimeError: acme_certificate[staging] (letsencrypt::http_authorization line 43) had an error: RuntimeError: ruby_block[create certificate for gitlab.kris.com] (letsencrypt::http_authorization line 110) had an error: RuntimeError: [gitlab.kris.com] Validation failed, unable to request certificate, Errors: [{url: https://acme-staging-v02.api.letsencrypt.org/acme/chall/225754544/19209370124/7rWJpA, status: invalid, error: {"type"=>"urn:ietf:params:acme:error:dns", "detail"=>"DNS problem: NXDOMAIN looking up A for gitlab.kris.com - check that a DNS record exists for this domain; DNS problem: NXDOMAIN looking up AAAA for gitlab.kris.com - check that a DNS record exists for this domain", "status"=>400}} ]
dpkg: error processing package gitlab-jh (--configure):
 installed gitlab-jh package post-installation script subprocess returned error exit status 1
Processing triggers for libc-bin (2.31-0ubuntu9.18) ...
Errors were encountered while processing:
 gitlab-jh
E: Sub-process /usr/bin/dpkg returned an error code (1)
```


以上报错是因为没有配域名导致的，在 hosts 里面添加以下内容：
```bash
kris@gitlab:~$ cat /etc/hosts
127.0.0.1 localhost
127.0.1.1 source

# 加上这一行就行，之前 EXTERNAL_URL配置的啥，这里就写啥，前面的 IP 就写本机 IP
192.168.10.10  gitlab.kris.com

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
kris@gitlab:~$
# 改好之后验证一下
kris@gitlab:~$ ping gitlab.kris.com
PING gitlab.kris.com (192.168.10.10) 56(84) bytes of data.
64 bytes from gitlab.kris.com (192.168.10.10): icmp_seq=1 ttl=64 time=0.021 ms
64 bytes from gitlab.kris.com (192.168.10.10): icmp_seq=2 ttl=64 time=0.021 ms
64 bytes from gitlab.kris.com (192.168.10.10): icmp_seq=3 ttl=64 time=0.024 ms
kris@gitlab:~$ dig A gitlab.kris.com +short
192.168.10.10
#然后重新配置gitlab
kris@gitlab:~$ sudo gitlab-ctl reconfigure
#最终显示如下结果就算成功了
Running handlers:
[2025-09-04T15:31:26+00:00] INFO: Running report handlers
Running handlers complete
[2025-09-04T15:31:26+00:00] INFO: Report handlers complete
Infra Phase complete, 167/1175 resources updated in 01 minutes 24 seconds

Deprecations:
Your OS, ubuntu-20.04, will be deprecated soon.
Starting with GitLab 18.9, packages will not be built for it.
Switch or upgrade to a supported OS, see https://docs.gitlab.com/ee/administration/package_information/supported_os.html for more information.

Update the configuration in your gitlab.rb file or GITLAB_OMNIBUS_CONFIG environment.

gitlab Reconfigured!
#到此还没有完全部署，go on...
```


##  安装 runner

更新apt包索引：
 sudo apt-get update
 安装必备的软件包以允许apt通过 HTTPS 使用存储库（repository）：
sudo apt-get install ca-certificates curl gnupg lsb-release

添加Docker官方版本库的GPG密钥：
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
使用以下命令设置存储库：
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

### 安装docker
```bash
sudo apt-get update
kris@gitlab:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

Unpacking slirp4netns (0.4.3-1) ...
Setting up slirp4netns (0.4.3-1) ...
Setting up docker-buildx-plugin (0.23.0-1~ubuntu.20.04~focal) ...
Setting up containerd.io (1.7.27-1) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
Setting up docker-compose-plugin (2.35.1-1~ubuntu.20.04~focal) ...
Setting up docker-ce-cli (5:28.1.1-1~ubuntu.20.04~focal) ...
Setting up pigz (2.4-1) ...
Setting up docker-ce-rootless-extras (5:28.1.1-1~ubuntu.20.04~focal) ...
Setting up docker-ce (5:28.1.1-1~ubuntu.20.04~focal) ...
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /lib/systemd/system/docker.service.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /lib/systemd/system/docker.socket.
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for systemd (245.4-4ubuntu3.20) ...

kris@gitlab:~$ sudo docker info
Client: Docker Engine - Community
 Version:    28.1.1
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.23.0
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.35.1
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 0






```