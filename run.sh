set -e

# Function Help
help() {
    echo "Usage: sudo $0 --path <directory> [--name <share_name>] [--user <user:password>]"
    echo ""
    echo "Options:"
    echo "  --path <directory>       Path folder sharing di Debian (REQUIRED)"
    echo "  --name <share_name>      Nama folder yang tampil di Windows (OPTIONAL, default: File Sharing)"
    echo "  --user <user:password>   Tambahkan user Samba (OPTIONAL)"
    echo "  --guest                  Izinkan akses anonim (tanpa login)"
    echo "  --no-guest               Nonaktifkan akses anonim (default)"
    echo "  -h, --help               Show this help"
    echo ""
    echo "Examples:"
    echo "  sudo $0 --path /home/share"
    echo "  sudo $0 --path /home/share --guest"
    echo "  sudo $0 --path /home/share --name 'Public Share'"
    echo "  sudo $0 --path /home/share --user sambauser:12345"
}

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

SHARE_NAME="File Sharing"
GUEST_ACCESS="yes"

while [ $# -gt 0 ]; do
    case "$1" in
        --path)
            SHARE_PATH="$2"
            shift 2
            ;;
        --name)
            SHARE_NAME="$2"
            shift 2
            ;;
        --user)
            IFS=':' read -r SAMBA_USER SAMBA_PASS <<< "$2"
            shift 2
            ;;
        --guest)
            GUEST_ACCESS="yes"
            shift
            ;;
        --no-guest)
            GUEST_ACCESS="no"
            shift
            ;;
        -h|--help)
            help
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            help
            exit 1
            ;;
    esac
done

if [ -z "$SHARE_PATH" ]; then
    echo "Error: --path is required."
    help
    exit 1
fi

# Install Samba
echo "[+] Installing Samba..."
apt update
apt install samba -y

echo "[+] Backup smb.conf..."
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

echo "[+] Create share directory: $SHARE_PATH"
mkdir -p "$SHARE_PATH"
chmod 777 "$SHARE_PATH"

# Samba config
CONFIG="[${SHARE_NAME}]
path = ${SHARE_PATH}
browsable = yes
writeable = yes
guest ok = ${GUEST_ACCESS}
read only = no"

if [ -n "$SAMBA_USER" ]; then
    CONFIG="${CONFIG}
valid users = ${SAMBA_USER}"
fi

echo "[+] Update /etc/samba/smb.conf..."
echo "" >> /etc/samba/smb.conf
echo "$CONFIG" >> /etc/samba/smb.conf

# Add Samba user if provided
if [ -n "$SAMBA_USER" ]; then
    echo "[+] Adding Linux user: $SAMBA_USER"
    if ! id "$SAMBA_USER" &>/dev/null; then
        adduser --disabled-password --gecos "" "$SAMBA_USER"
    fi

    echo "$SAMBA_USER:$SAMBA_PASS" | chpasswd
    (echo "$SAMBA_PASS"; echo "$SAMBA_PASS") | smbpasswd -a -s "$SAMBA_USER"
    smbpasswd -e "$SAMBA_USER"

    chown "$SAMBA_USER:$SAMBA_USER" "$SHARE_PATH"
fi

# Restart Samba service
echo "[+] Restarting Samba..."
systemctl restart smbd

IP=$(ip -4 addr show scope global | awk '/inet/ {print $2}' | cut -d/ -f1 | head -n 1)

echo
echo "[+] Samba share ready!"
echo "Windows access: \\\\$IP\\$SHARE_NAME"
echo "Guest access: $GUEST_ACCESS"
