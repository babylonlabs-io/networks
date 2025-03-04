# Babylon Staking Indexer

The Babylon Staking Indexer is a tool that extracts staking-relevant data from both the Babylon blockchain and the Bitcoin blockchain. It processes, validates, and stores staking transactions, and gathers data about their status. This indexer serves as a data aggregation and transformation layer, making blockchain data available in an API-friendly format for dApps to use. 

## Hardware Requirements

- **CPU:** Multi-core processor (4 cores minimum)
- **Memory:** Minimum 4GB RAM (recommended 8GB RAM)
- **Storage:** Sufficient space for MongoDB data (at least 10GB recommended)

## Configuration

### 1. Create Home Directory
```bash
mkdir -p ~/.babylon-staking-indexer/
```

### 2. Copy the Default Configuration
```bash
cp ~/babylon-staking-indexer/config/config-local.yml ~/.babylon-staking-indexer/config.yml
```

### 3. Update Default Configurations

Edit the `config.yml` file to match your environment:

#### MongoDB Cluster Connection
Set the MongoDB connection address (`address`) and credentials (`username`, `password`, and `db-name`) to match the information from your installed MongoDB cluster.

```yaml
db:
  address: "mongodb://localhost:27019/?replicaSet=RS&directConnection=true"
  username: "root"
  password: "example"
  db-name: "babylon-staking-indexer"
```

#### Bitcoin Node Connection
Configure the Bitcoin node connection details to match your Bitcoin node installation.

```yaml
btc:
  rpchost: 127.0.0.1:38332 
  rpcuser: rpcuser
  rpcpass: rpcpass
  netparams: signet
```

#### Babylon Node Connection
Set the Babylon RPC address and connection parameters.

```yaml
bbn:
  rpc-addr: https://rpc-dapp.devnet.babylonlabs.io:443
  timeout: 30s
```

#### RabbitMQ Cluster Connection
Set the RabbitMQ connection address (`url`) and credentials (`queue_user` and `queue_password`) to match the information from your installed RabbitMQ cluster.

```yaml
queue:
  queue_user: user
  queue_password: password
  url: "localhost:5672"
  queue_type: quorum
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

Runs the Babylon Staking Indexer image from official Babylon Docker Hub repository:

```bash
docker run -d --name babylon-staking-indexer \
  -v ~/.babylon-staking-indexer/config.yml:/app/config.yml \
  babylonlabs/babylon-staking-indexer:latest --config /app/config.yml
```

This approach is recommended for production environments as it provides better isolation and simplified deployment.

### Method B: Local Binary Execution

#### 1. Clone the Repository
```bash
git clone https://github.com/babylonlabs-io/babylon-staking-indexer.git
```

#### 2. Check Out the Desired Version
You can find the latest release [here](https://github.com/babylonlabs-io/babylon-staking-indexer/releases).

```bash
cd babylon-staking-indexer
git checkout tags/{VERSION}
```

#### 3. Install the Binary
```bash
make install
```
This command will build and install the binary to your GOPATH.

#### 4. Start the Indexer
You can start the Staking Indexer by running:

```bash
babylon-staking-indexer --config ~/.babylon-staking-indexer/config.yml
```

## Create Systemd Service (Linux Only)

#### 1. Create Systemd Service Definition
Run the following command, replacing `system_username` with the appropriate system user or service account name:

```bash
cat <<EOF | sudo tee /etc/systemd/system/babylon-staking-indexer.service
[Unit]
Description=Babylon Staking Indexer service
After=network.target

[Service]
Type=simple
ExecStart=$(which babylon-staking-indexer) --config /home/system_username/.babylon-staking-indexer/config.yml
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
sudo systemctl enable babylon-staking-indexer.service
```

#### 4. Start the Service
```bash
sudo systemctl start babylon-staking-indexer.service
```

#### 5. Verify the Service
Check service status:
```bash
sudo systemctl status babylon-staking-indexer.service
```

Expected log output will confirm the service is active.

## Monitoring

The service exposes Prometheus metrics through a Prometheus server. By default, it is available at the address configured in the metrics configuration section (0.0.0.0:2112). Configure the metrics endpoint in your configuration file as needed.
