# Staking Expiry Checker

## 1. Hardware Requirements

- CPU: Multi-core processor (4 cores minimum)
- Memory: Minimum 4GB RAM (recommended 8GB RAM)

## 2. Install Staking Expiry Checker

### 2.1 Clone Repository
Clone the repository to your local machine from GitHub:
```bash
git clone https://github.com/babylonlabs-io/staking-expiry-checker.git
```

### 2.2 Check Out Desired Version
After cloning, navigate into the repository and check out the desired version:
```bash
cd staking-expiry-checker  
git checkout tags/{VERSION}  
```
*You can find the latest release [here](https://github.com/babylonlabs-io/staking-expiry-checker/releases).*

### 2.3 Install the Binary
Install the binary by running:
```bash
make install
```

## 3. Configuration

### 3.1 Create Home Directory
Create the home directory:
```bash
mkdir -p ~/.staking-expiry-checker/
```

### 3.2 Copy Default Configuration
Copy the default configuration file:
```bash
cp ~/staking-expiry-checker/config/config-local.yml ~/.staking-expiry-checker/config.yml
```

### 3.3 Update Default Configurations

#### MongoDB Cluster
Set the MongoDB connection address and credentials to match your [installed MongoDB cluster](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/infra/mongodb):
```bash
db:
  username: "<admin>"
  password: "<password>"
  address: "mongodb://localhost:27017/?directConnection=true"
  db-name: "<db-name>"
```

#### Bitcoin Node
Set the Bitcoin node connection address and credentials to match your [installed Bitcoin node](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/infra/bitcoind):
```bash
btc:
  endpoint: localhost:18332
  disable-tls: false
  net-params: testnet
  rpc-user: rpcuser
  rpc-pass: rpcpass
```

#### RabbitMQ Cluster
Set the RabbitMQ connection address (`url`) and credentials (`queue_user` and `queue_password`) to match your [installed RabbitMQ cluster](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/infra/rabbitmq):
```bash
queue:
  queue_user: admin
  queue_password: password
  url: "localhost:5672"
```

#### Prometheus Metrics
Customize the `host` and `port` for Prometheus metrics exposure:
```bash
metrics:
  host: 0.0.0.0
  port: 2112
```

## 4. Start Staking Expiry Checker

Start the staking-expiry-checker by running:
```bash
staking-expiry-checker --config ~/.staking-expiry-checker/config.yml
```

## 5. Create systemd Service (Optional - Linux Only)

### 5.1 Create Service Definition
Run the following command, replacing `system_username` with the appropriate system user or service account name:
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

### 5.2 Reload systemd Configuration
Reload the systemd manager configuration:
```bash
sudo systemctl daemon-reload
```

### 5.3 Enable the Service at Boot
Enable the service to start on boot:
```bash
sudo systemctl enable staking-expiry-checker.service
```

### 5.4 Start the Service
Start the service:
```bash
sudo systemctl start staking-expiry-checker.service
```

## 6. Monitoring

The service exposes Prometheus metrics through a Prometheus server, which is reachable by default at `127.0.0.1:2112`.