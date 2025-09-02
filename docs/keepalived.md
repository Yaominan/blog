## keepalived
1. 用keepalived实现服务器主备高可用
```bash
# 安装keepalived
[root@Test1 ~]# yum -y install keepalived

# 修改配置文件
[root@Test1 ~]# cat /etc/keepalived/keepalived.conf 
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   #router_id LVS_DEVEL
   router_id Test1
   vrrp_skip_check_adv_addr
   #vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens32
    virtual_router_id 66
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.10.5/24 dev ens32 label ens32:0
    }
}

```

```bash
# 配置解析，根据主备的具体情况修改
#vrrp_strict            这一项需要注释掉，否则会走防火墙策略
router_id Test1         写主机名就行
state BACKUP            根据主备机器修改  主：MASTER  备：BACKUP
interface ens32         填写承载虚拟IP的网卡，不是固定的，需要根据机器实际的网卡名修改
virtual_router_id 66    修改路由id的优先级，具体哪台机器是主，哪台机器是备通过这个优先级决定
authentication {
	auth_type PASS
	auth_pass 123456    可以改个密码
}
virtual_ipaddress {
	192.168.10.5/24 dev ens32 label ens32:0     修改默认的虚拟IP，以及承载ip的网卡设备
}
```
2. keepalived双主机互为主备
	规则：以一个虚拟ip分组归为同一个路由
![[Pasted image 20250326094255.png]]
```bash
# 主节点配置
global_defs {
   router_id keep_104
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.108
    }
}

vrrp_instance VI_2 {
    state BACKUP
    interface ens33
    virtual_router_id 52
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.138
    }
}

```

```bash
# 备用节点配置
global_defs {
   router_id keep_105
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens33
    virtual_router_id 51
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.108
    }
}

vrrp_instance VI_2 {
    state MASTER
    interface ens33
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.138
    }
}
```
> keepalived 双主机互为主备其实和热备差不多，只是通过两组不同路由 id 来管理，id 51 设为A机器是主、B机器是备；id 52 设为A机器是备，B机器是主；具体主备设置通过配置 ***priority*** 优先级实现