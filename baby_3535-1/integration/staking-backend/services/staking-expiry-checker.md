# Babylon Staking Expiry Checker

The Babylon Staking Expiry Checker is a service that manages unbonding and
withdrawal processes for Phase 1 delegations that haven't transitioned to Phase
2. This service ensures the integrity and proper state management of staking
transactions throughout their lifecycle.

## Hardware Requirements

- **CPU:** Multi-core processor (4 cores minimum)
- **Memory:** Minimum 4GB RAM (recommended 8GB RAM)

## Configuration

### 1. Create Home Directory
```bash
mkdir -p ~/.staking-expiry-checker/
```

### 2. Copy the Default Configuration
```bash
cp ~/staking-expiry-checker/config/config-local.yml ~/.staking-expiry-checker/config.yml
```

### 3. Update Default Configurations

Edit the `config.yml` file to match your environment:

#### MongoDB Cluster Connection
Set the MongoDB connection address (`address`) and credentials (`username`,
`password`, and `db-name`) to match the information from your installed MongoDB
cluster.

```yaml
db:
  address: "mongodb://localhost:27017/?directConnection=true"
  username: "<admin>"
  password: "<password>"
  db-name: "<db-name>"
```

#### Bitcoin Node Connection
Configure the Bitcoin node connection details to match your Bitcoin node
installation.

```yaml
btc:
  endpoint: localhost:18332
  disable-tls: false
  net-params: mainnet
  rpc-user: rpcuser
  rpc-pass: rpcpass
```

#### RabbitMQ Cluster Connection
Set the RabbitMQ connection address (`url`) and credentials (`queue_user` and
`queue_password`) to match the information from your installed RabbitMQ cluster.

```yaml
queue:
  queue_user: admin
  queue_password: password
  url: "localhost:5672"
```

#### Prometheus Metrics Configuration
Set the host and port to customize how the metrics are exposed.

```yaml
metrics:
  host: 0.0.0.0
  port: 2112
```

## Start the Service

### Method A: Docker Deployment (Recommended)

Runs the Staking Expiry Checker image from official Babylon Docker Hub
repository:

```bash
docker run -d --name staking-expiry-checker \
  -v ~/.staking-expiry-checker/config.yml:/app/config.yml \
  babylonlabs/staking-expiry-checker:v1.0.0 --config /app/config.yml
```

This approach is recommended for production environments as it provides better
isolation and simplified deployment.

### Method B: Local Binary Execution

#### 1. Clone the Repository
```bash
git clone https://github.com/babylonlabs-io/staking-expiry-checker.git
```

#### 2. Check Out the Desired Version
You can find the latest release
[here](https://github.com/babylonlabs-io/staking-expiry-checker/releases).

```bash
cd staking-expiry-checker
git checkout tags/{VERSION}
```

#### 3. Install the Binary
```bash
make install
```
This command will build and install the binary to your GOPATH.

#### 4. Start the Expiry Checker
You can start the Staking Expiry Checker by running:

```bash
staking-expiry-checker --config ~/.staking-expiry-checker/config.yml
```

## Create Systemd Service (Linux Only)

#### 1. Create Systemd Service Definition
Run the following command, replacing `system_username` with the appropriate
system user or service account name:

```bash
cat <<EOF | sudo tee /etc/systemd/system/staking-expiry-checker.service
[Unit]
Description=Staking Expiry Checker service
After=network.target

[Service]
Type=simple
ExecStart=$(which staking-expiry-checker) --config /home/system_username/.staking-expiry-checker/config.yml
Restart=on-failure
User=system_username

[Install]
WantedBy=multi-user.target
EOF
```

#### 2. Reload Systemd Configuration
```bash
sudo systemctl daemon-reload
```

#### 3. Enable the Service at Boot
```bash
sudo systemctl enable staking-expiry-checker.service
```

#### 4. Start the Service
```bash
sudo systemctl start staking-expiry-checker.service
```

#### 5. Verify the Service
Check service status:
```bash
sudo systemctl status staking-expiry-checker.service
```

Expected log output will confirm the service is active.

## Monitoring

The service exposes Prometheus metrics through a Prometheus server. By default,
it is available at the address configured in the metrics configuration section
(0.0.0.0:2112). Configure the metrics endpoint in your configuration file as
needed.

## Backup

The Staking Expiry Checker is stateless, so no backups are needed.  
