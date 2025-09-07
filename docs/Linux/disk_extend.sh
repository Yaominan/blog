#!/bin/bash

#########################################################
# 通用Linux磁盘扩容脚本                                 #
# 用途：在虚拟机或云环境中扩展磁盘空间                  #
# 支持：大多数Linux发行版（Ubuntu, CentOS, RHEL等）     #
# 作者：Kris                                           #
# 日期：$(date +"%Y-%m-%d")                            #
#########################################################

# 颜色定义
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # 恢复默认颜色


timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# 日志函数
log_info() {
    echo -e "${GREEN}$(timestamp)-[INFO]  $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}$(timestamp)-[WARN]  $1${NC}"
}

log_error() {
    echo -e "${RED}$(timestamp)-[ERROR]  $1${NC}"
}

log_debug() {
    if [ "$DEBUG" = "true" ]; then
        echo -e "${BLUE}$(timestamp)-[DEBUG]${NC} $1"
    fi
}

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "此脚本需要root权限运行"
        log_info "请使用 'sudo $0' 重新运行"
        exit 1
    fi
}

# 检测Linux发行版
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        log_info "检测到操作系统: $OS $VERSION"
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        log_info "检测到Red Hat系统"
    else
        OS="unknown"
        log_warn "无法确定操作系统类型，将尝试通用方法"
    fi
}

# 检查命令是否存在
check_command() {
    command -v "$1" &>/dev/null
}

# 安装必要工具
install_tools() {
    log_info "检查并安装必要工具..."
    
    # 定义需要的工具列表
    local tools_to_check=()
    local missing_tools=()
    
    # 根据操作系统定义工具包名称和对应命令
    case $OS in
        ubuntu|debian)
            tools_to_check=("growpart:cloud-guest-utils" "pvs:lvm2" "resize2fs:e2fsprogs" "xfs_growfs:xfsprogs" "btrfs:btrfs-progs" "parted:parted")
            ;;
        centos|rhel|fedora)
            tools_to_check=("growpart:cloud-utils-growpart" "pvs:lvm2" "resize2fs:e2fsprogs" "xfs_growfs:xfsprogs" "btrfs:btrfs-progs" "parted:parted")
            ;;
        suse|opensuse*)
            tools_to_check=("growpart:growpart" "pvs:lvm2" "resize2fs:e2fsprogs" "xfs_growfs:xfsprogs" "btrfs:btrfs-progs" "parted:parted")
            ;;
        *)
            if command -v apt &>/dev/null; then
                tools_to_check=("growpart:cloud-guest-utils" "pvs:lvm2" "resize2fs:e2fsprogs" "xfs_growfs:xfsprogs" "btrfs:btrfs-progs" "parted:parted")
            elif command -v yum &>/dev/null; then
                tools_to_check=("growpart:cloud-utils-growpart" "pvs:lvm2" "resize2fs:e2fsprogs" "xfs_growfs:xfsprogs" "btrfs:btrfs-progs" "parted:parted")
            elif command -v zypper &>/dev/null; then
                tools_to_check=("growpart:growpart" "pvs:lvm2" "resize2fs:e2fsprogs" "xfs_growfs:xfsprogs" "btrfs:btrfs-progs" "parted:parted")
            else
                log_error "无法确定包管理器，请手动安装必要工具后重试"
                exit 1
            fi
            ;;
    esac
    
    # 检查每个命令是否存在，如果不存在则添加到缺失列表
    for tool_info in "${tools_to_check[@]}"; do
        IFS=':' read -r cmd pkg <<< "$tool_info"
        if ! check_command "$cmd"; then
            log_debug "命令 '$cmd' 不存在，需要安装 '$pkg'"
            missing_tools+=("$pkg")
        else
            log_debug "命令 '$cmd' 已存在，无需安装"
        fi
    done
    
    # 如果有缺失的工具，则安装
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_info "安装缺失的工具: ${missing_tools[*]}"
        
        case $OS in
            ubuntu|debian)
                apt update -qq
                apt install -y "${missing_tools[@]}"
                ;;
            centos|rhel|fedora)
                yum install -y "${missing_tools[@]}"
                ;;
            suse|opensuse*)
                zypper install -y "${missing_tools[@]}"
                ;;
            *)
                if command -v apt &>/dev/null; then
                    apt update -qq
                    apt install -y "${missing_tools[@]}"
                elif command -v yum &>/dev/null; then
                    yum install -y "${missing_tools[@]}"
                elif command -v zypper &>/dev/null; then
                    zypper install -y "${missing_tools[@]}"
                fi
                ;;
        esac
        
        log_info "工具安装完成"
    else
        log_info "所有必要工具已存在，无需安装"
    fi
}

# 检测磁盘类型（固态或机械）
detect_disk_type() {
    local disk_name=$(basename $1)
    
    # 检查是否为固态硬盘
    if [ -e "/sys/block/$disk_name/queue/rotational" ]; then
        local rotational=$(cat /sys/block/$disk_name/queue/rotational)
        if [ "$rotational" = "0" ]; then
            log_info "检测到固态硬盘: $1"
            IS_SSD=true
        else
            log_info "检测到机械硬盘: $1"
            IS_SSD=false
        fi
    else
        # 尝试使用lsblk检测
        if lsblk -d -o name,rota | grep "$(basename $1)" | grep -q "0"; then
            log_info "检测到固态硬盘: $1"
            IS_SSD=true
        else
            log_warn "无法确定硬盘类型，默认按机械硬盘处理: $1"
            IS_SSD=false
        fi
    fi
}

# 检测根分区所在磁盘和分区
detect_root_disk() {
    log_info "检测根分区所在磁盘和分区..."
    
    # 检查df命令是否存在
    if ! check_command "df"; then
        log_error "未找到df命令，无法检测根分区"
        exit 1
    fi
    
    # 获取根分区挂载点
    ROOT_MOUNT=$(df -h / | grep -v Filesystem | awk '{print $1}')
    log_debug "根挂载点: $ROOT_MOUNT"
    
    # 检查是否为LVM
    if [[ $ROOT_MOUNT == *mapper* ]]; then
        # 检查LVM相关命令是否存在
        if ! check_command "lvdisplay" || ! check_command "pvdisplay" || ! check_command "pvs"; then
            log_error "未找到LVM相关命令，无法处理LVM卷"
            exit 1
        fi
        
        IS_LVM=true
        LVM_VG=$(lvdisplay $ROOT_MOUNT | grep "VG Name" | awk '{print $3}')
        LVM_LV=$(lvdisplay $ROOT_MOUNT | grep "LV Name" | awk '{print $3}')
        log_info "检测到LVM卷组: $LVM_VG, 逻辑卷: $LVM_LV"
        
        # 获取物理卷和分区
        PV_LIST=$(pvdisplay | grep "PV Name" | awk '{print $3}')
        for PV in $PV_LIST; do
            if pvs $PV | grep -q $LVM_VG; then
                ROOT_PV=$PV
                break
            fi
        done
        
        if [ -z "$ROOT_PV" ]; then
            log_error "无法确定根分区所在的物理卷"
            exit 1
        fi
        
        # 从物理卷获取分区和磁盘
        ROOT_PART=$ROOT_PV
        ROOT_DISK=$(echo $ROOT_PART | sed 's/[0-9]*$//')
        PART_NUM=$(echo $ROOT_PART | grep -o '[0-9]*$')
        
        log_info "根分区位于物理卷: $ROOT_PV, 磁盘: $ROOT_DISK, 分区号: $PART_NUM"
    else
        IS_LVM=false
        # 直接分区
        ROOT_PART=$ROOT_MOUNT
        ROOT_DISK=$(echo $ROOT_PART | sed 's/[0-9]*$//')
        PART_NUM=$(echo $ROOT_PART | grep -o '[0-9]*$')
        
        log_info "根分区直接挂载在: $ROOT_PART, 磁盘: $ROOT_DISK, 分区号: $PART_NUM"
    fi
    
    # 检测文件系统类型
    FS_TYPE=$(df -T / | grep -v Filesystem | awk '{print $2}')
    log_info "根分区文件系统类型: $FS_TYPE"
    
    # 检测磁盘类型（固态或机械）
    detect_disk_type $ROOT_DISK
}

# 刷新磁盘大小
rescan_disk() {
    log_info "刷新磁盘 $ROOT_DISK 大小..."
    
    # 获取磁盘名称（不含路径）
    DISK_NAME=$(basename $ROOT_DISK)
    
    # 尝试多种方法刷新磁盘大小
    if [ -e "/sys/class/block/$DISK_NAME/device/rescan" ]; then
        echo 1 > "/sys/class/block/$DISK_NAME/device/rescan"
        log_info "使用 sysfs 刷新磁盘大小成功"
    elif [ -e "/sys/class/scsi_device/" ]; then
        # SCSI设备刷新方法
        for SCSI_DEVICE in /sys/class/scsi_device/*; do
            echo 1 > "$SCSI_DEVICE/device/rescan"
        done
        log_info "使用 SCSI 设备刷新磁盘大小成功"
    else
        log_warn "无法自动刷新磁盘大小，可能需要重启系统才能识别新的磁盘大小"
    fi
    
    # 显示磁盘大小信息
    log_info "磁盘 $ROOT_DISK 当前大小:"
    if check_command "fdisk"; then
        fdisk -l $ROOT_DISK | grep Disk
    elif check_command "lsblk"; then
        lsblk $ROOT_DISK
    else
        log_warn "未找到fdisk或lsblk命令，无法显示磁盘大小信息"
    fi
}

# 扩展分区
extend_partition() {
    log_info "扩展分区 $ROOT_PART..."
    
    # 检查growpart命令是否存在
    if ! check_command "growpart"; then
        log_error "未找到growpart命令，无法扩展分区"
        exit 1
    fi
    
    # 使用growpart扩展分区
    growpart $ROOT_DISK $PART_NUM
    
    if [ $? -eq 0 ]; then
        log_info "分区扩展成功"
    else
        log_warn "分区扩展失败或分区已经是最大大小"
    fi
    
    # 显示分区信息
    log_info "分区 $ROOT_PART 当前大小:"
    if check_command "fdisk"; then
        fdisk -l $ROOT_PART | grep $ROOT_PART || lsblk $ROOT_PART
    elif check_command "lsblk"; then
        lsblk $ROOT_PART
    else
        log_warn "未找到fdisk或lsblk命令，无法显示分区信息"
    fi
}

# 扩展物理卷（如果使用LVM）
extend_pv() {
    if [ "$IS_LVM" = true ]; then
        log_info "扩展物理卷 $ROOT_PV..."
        
        # 检查pvresize命令是否存在
        if ! check_command "pvresize"; then
            log_error "未找到pvresize命令，无法扩展物理卷"
            exit 1
        fi
        
        pvresize $ROOT_PV
        
        if [ $? -eq 0 ]; then
            log_info "物理卷扩展成功"
            if check_command "pvs"; then
                pvs $ROOT_PV
            else
                log_warn "未找到pvs命令，无法显示物理卷信息"
            fi
        else
            log_error "物理卷扩展失败"
            exit 1
        fi
    else
        log_debug "不是LVM配置，跳过物理卷扩展"
    fi
}

# 扩展逻辑卷（如果使用LVM）
extend_lv() {
    if [ "$IS_LVM" = true ]; then
        log_info "扩展逻辑卷 $LVM_VG/$LVM_LV..."
        
        # 检查lvextend命令是否存在
        if ! check_command "lvextend"; then
            log_error "未找到lvextend命令，无法扩展逻辑卷"
            exit 1
        fi
        
        lvextend -l +100%FREE /dev/$LVM_VG/$LVM_LV
        
        if [ $? -eq 0 ]; then
            log_info "逻辑卷扩展成功"
            if check_command "lvs"; then
                lvs /dev/$LVM_VG/$LVM_LV
            else
                log_warn "未找到lvs命令，无法显示逻辑卷信息"
            fi
        else
            log_error "逻辑卷扩展失败"
            exit 1
        fi
    else
        log_debug "不是LVM配置，跳过逻辑卷扩展"
    fi
}

# 扩展文件系统
extend_filesystem() {
    if [ "$IS_LVM" = true ]; then
        TARGET=$ROOT_MOUNT
    else
        TARGET=$ROOT_PART
    fi
    
    log_info "扩展文件系统 $TARGET (类型: $FS_TYPE)..."
    
    case $FS_TYPE in
        ext2|ext3|ext4)
            # 检查resize2fs命令是否存在
            if ! check_command "resize2fs"; then
                log_error "未找到resize2fs命令，无法扩展ext文件系统"
                exit 1
            fi
            
            # 对于固态硬盘，添加-E选项以优化扩展操作
            if [ "$IS_SSD" = true ]; then
                log_info "检测到固态硬盘，使用优化参数进行扩展"
                # 检查resize2fs版本是否支持-E选项
                if resize2fs -h 2>&1 | grep -q -- "-E"; then
                    resize2fs -E discard $TARGET
                else
                    log_warn "当前resize2fs版本不支持-E选项，使用标准模式扩展"
                    resize2fs $TARGET
                fi
            else
                resize2fs $TARGET
            fi
            ;;
        xfs)
            # 检查xfs_growfs命令是否存在
            if ! check_command "xfs_growfs"; then
                log_error "未找到xfs_growfs命令，无法扩展XFS文件系统"
                exit 1
            fi
            
            # XFS文件系统扩展
            xfs_growfs $TARGET
            
            # 如果是固态硬盘，执行TRIM操作
            if [ "$IS_SSD" = true ]; then
                if check_command "fstrim"; then
                    log_info "对固态硬盘执行TRIM操作"
                    fstrim -v /
                else
                    log_warn "未找到fstrim命令，跳过TRIM操作"
                fi
            fi
            ;;
        btrfs)
            # 检查btrfs命令是否存在
            if ! check_command "btrfs"; then
                log_error "未找到btrfs命令，无法扩展Btrfs文件系统"
                exit 1
            fi
            
            btrfs filesystem resize max $TARGET
            
            # 如果是固态硬盘，执行TRIM操作
            if [ "$IS_SSD" = true ]; then
                if check_command "fstrim"; then
                    log_info "对固态硬盘执行TRIM操作"
                    fstrim -v /
                else
                    log_warn "未找到fstrim命令，跳过TRIM操作"
                fi
            fi
            ;;
        *)
            log_error "不支持的文件系统类型: $FS_TYPE"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_info "文件系统扩展成功"
    else
        log_error "文件系统扩展失败"
        exit 1
    fi
}

# 显示扩容结果
show_result() {
    log_info "磁盘扩容完成，当前磁盘使用情况:"
    if check_command "df"; then
        df -h /
    else
        log_warn "未找到df命令，无法显示磁盘使用情况"
    fi
}

# 为固态硬盘配置优化参数
optimize_ssd() {
    if [ "$IS_SSD" = true ]; then
        log_info "为固态硬盘配置优化参数..."
        
        # 检查fstrim命令是否存在
        if ! check_command "fstrim"; then
            log_warn "未找到fstrim命令，尝试安装util-linux或相关包"
            case $OS in
                ubuntu|debian)
                    apt update -qq
                    apt install -y util-linux
                    ;;
                centos|rhel|fedora)
                    yum install -y util-linux
                    ;;
                suse|opensuse*)
                    zypper install -y util-linux
                    ;;
                *)
                    if command -v apt &>/dev/null; then
                        apt update -qq
                        apt install -y util-linux
                    elif command -v yum &>/dev/null; then
                        yum install -y util-linux
                    elif command -v zypper &>/dev/null; then
                        zypper install -y util-linux
                    else
                        log_error "无法安装fstrim工具，TRIM功能将不可用"
                        return 1
                    fi
                    ;;
            esac
            
            # 再次检查fstrim是否安装成功
            if ! check_command "fstrim"; then
                log_error "安装fstrim失败，TRIM功能将不可用"
                return 1
            fi
        fi
        
        # 检查是否已启用TRIM
        if ! grep -q "discard" /etc/fstab; then
            log_info "添加TRIM支持到fstab"
            # 检查sed命令是否存在
            if ! check_command "sed"; then
                log_error "未找到sed命令，无法修改fstab"
                return 1
            fi
            # 备份fstab
            cp /etc/fstab /etc/fstab.bak
            # 为根分区添加discard选项
            sed -i 's|\(\s\+/\s\+\w\+\s\+\)\(.*\)|\1discard,\2|' /etc/fstab
        else
            log_debug "TRIM已在fstab中配置"
        fi
        
        # 检查是否已启用fstrim定时任务
        if [ -d "/etc/cron.weekly" ] && [ ! -f "/etc/cron.weekly/fstrim" ]; then
            log_info "添加每周TRIM定时任务"
            cat > /etc/cron.weekly/fstrim << 'EOF'
#!/bin/sh
# 每周对所有支持TRIM的挂载点执行TRIM操作
/sbin/fstrim -av
EOF
            chmod +x /etc/cron.weekly/fstrim
        elif [ -d "/etc/systemd/system" ] && [ ! -f "/etc/systemd/system/fstrim.timer" ]; then
            # 对于使用systemd的系统，启用fstrim.timer
            if check_command "systemctl" && systemctl list-unit-files fstrim.timer &>/dev/null; then
                log_info "启用systemd fstrim.timer服务"
                systemctl enable fstrim.timer
                systemctl start fstrim.timer
            fi
        fi
        
        # 执行一次TRIM操作
        log_info "执行TRIM操作..."
        fstrim -av
    fi
}

# 主函数
main() {
    # 设置调试模式（可选）
    DEBUG=${DEBUG:-false}
    IS_SSD=false
    
    log_info "开始磁盘扩容过程..."
    
    # 检查root权限
    check_root
    
    # 检测操作系统
    detect_os
    
    # 安装必要工具
    install_tools
    
    # 检测根分区所在磁盘和分区
    detect_root_disk
    
    # 刷新磁盘大小
    rescan_disk
    
    # 扩展分区
    extend_partition
    
    # 扩展物理卷（如果使用LVM）
    extend_pv
    
    # 扩展逻辑卷（如果使用LVM）
    extend_lv
    
    # 扩展文件系统
    extend_filesystem
    
    # 为固态硬盘配置优化参数
    optimize_ssd
    
    # 显示结果
    show_result
    
    log_info "磁盘扩容成功完成！"
}

# 执行主函数
main "$@"