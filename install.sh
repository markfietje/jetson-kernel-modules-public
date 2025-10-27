#!/bin/bash

# Jetson Kernel Modules Installation Script
# Installs XFS filesystem and NFS server modules for Jetson 4.9.x kernels

set -e

echo "🚀 Installing Jetson kernel modules..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

# Check kernel version
KERNEL_VERSION=$(uname -r)
if [[ ! $KERNEL_VERSION =~ ^4\.9\. ]]; then
    echo "⚠️  Warning: This package is designed for kernel 4.9.x"
    echo "   Current kernel: $KERNEL_VERSION"
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get system architecture
ARCH=$(uname -m)
if [[ $ARCH != "aarch64" ]]; then
    echo "⚠️  Warning: This package is designed for ARM64 (aarch64)"
    echo "   Current architecture: $ARCH"
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Module installation directory
MODULE_DIR="/lib/modules/$KERNEL_VERSION"

echo "📁 Installing modules to $MODULE_DIR..."

# Create module directories
mkdir -p "$MODULE_DIR/fs/xfs"
mkdir -p "$MODULE_DIR/fs/nfsd"
mkdir -p "$MODULE_DIR/fs/nfs_common"
mkdir -p "$MODULE_DIR/fs/lockd"
mkdir -p "$MODULE_DIR/lib"
mkdir -p "$MODULE_DIR/net/sunrpc"
mkdir -p "$MODULE_DIR/net/sunrpc/auth_gss"

# Copy kernel modules
echo "📦 Copying kernel modules..."
cp fs/xfs/xfs.ko "$MODULE_DIR/fs/xfs/"
cp fs/nfsd/nfsd.ko "$MODULE_DIR/fs/nfsd/"
cp fs/nfs_common/nfs_acl.ko "$MODULE_DIR/fs/nfs_common/"
cp fs/nfs_common/grace.ko "$MODULE_DIR/fs/nfs_common/"
cp fs/lockd/lockd.ko "$MODULE_DIR/fs/lockd/"
cp lib/libcrc32c.ko "$MODULE_DIR/lib/"
cp net/sunrpc/sunrpc.ko "$MODULE_DIR/net/sunrpc/"
cp net/sunrpc/auth_gss/auth_rpcgss.ko "$MODULE_DIR/net/sunrpc/auth_gss/"

# Set proper permissions
chmod 644 "$MODULE_DIR"/fs/**/*.ko
chmod 644 "$MODULE_DIR"/lib/*.ko
chmod 644 "$MODULE_DIR"/net/**/*.ko

# Update module dependencies
echo "🔄 Updating module dependencies..."
depmod -a

# Load modules
echo "🔌 Loading kernel modules..."
modprobe libcrc32c
modprobe sunrpc
modprobe lockd
modprobe grace
modprobe nfs_acl
modprobe auth_rpcgss
modprobe nfsd
modprobe xfs

# Install NFS server utilities if not present
if ! command -v exportfs &> /dev/null; then
    echo "📥 Installing NFS server utilities..."
    apt-get update
    apt-get install -y nfs-kernel-server
fi

# Configure NFS server
echo "⚙️  Configuring NFS server..."
systemctl enable rpcbind
systemctl enable nfs-kernel-server
systemctl start rpcbind
systemctl start nfs-kernel-server

# Verify installation
echo "✅ Verifying installation..."
if lsmod | grep -q "xfs"; then
    echo "   ✅ XFS module loaded"
else
    echo "   ❌ XFS module not loaded"
fi

if lsmod | grep -q "nfsd"; then
    echo "   ✅ NFS server module loaded"
else
    echo "   ❌ NFS server module not loaded"
fi

if systemctl is-active --quiet nfs-kernel-server; then
    echo "   ✅ NFS server service running"
else
    echo "   ❌ NFS server service not running"
fi

echo ""
echo "🎉 Installation completed successfully!"
echo ""
echo "📚 Next steps:"
echo "   • Mount XFS filesystems: sudo mount -t xfs /dev/sdXn /mnt/point"
echo "   • Configure NFS exports: edit /etc/exports"
echo "   • View documentation: https://markfietje.github.io/jetson-kernel-modules-public/"
echo ""
echo "💡 Need help? Check the troubleshooting guide in the documentation."
