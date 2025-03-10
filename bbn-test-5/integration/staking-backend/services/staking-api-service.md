# Babylon Staking API Service

The Babylon Staking API Service provides a performant interface between Babylon
Phase-2 and application layers. It transforms blockchain data for efficient
access by dApps, serves network state information, and processes unbonding
requests for Phase-1 delegations.

> **Note:** Phase-1 delegations are now in maintenance mode.

## Hardware Requirements

- **CPU:** Multi-core processor (4 cores minimum)
- **Memory:** Minimum 4GB RAM (recommended 8GB RAM)

## Configuration

### 1. Create Home Directory
```bash
mkdir -p ~/.staking-api-service/
```

### 2. Copy the Default Configuration
```bash
cp ~/staking-api-service/config/config-local.yml ~/.staking-api-service/config.yml
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
  username: "<username>"
  password: "<password>"
  db-name: "<db-name>"
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

### 4. Download Global Parameters

To run the Staking API, a `global-params.json` file which defines all the
staking parameters is needed.

To download the global parameters, follow the instructions at:
[Staking Parameters Documentation](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/global-params#staking-parameters)

### 5. Download Finality Providers

To run the Staking API, a `finality-provider.json` file that associates finality
provider BTC public keys with additional information about them such as their
moniker and commission is needed.

To generate the concatenated finality providers information from Babylon
registry, follow the instructions at:
[Finality Providers Documentation](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/global-params#22-generating-concatenated-finality-provider-information)

## Start the Service

### Method A: Docker Deployment (Recommended)

Runs the Staking API Service image from official Babylon Docker Hub repository:

```bash
docker run -d --name staking-api-service \
  -v ~/.staking-api-service/config.yml:/app/config.yml \
  -v ~/.staking-api-service/global-params.json:/app/global-params.json \
  -v ~/.staking-api-service/finality-providers.json:/app/finality-providers.json \
  babylonlabs/staking-api-service:latest \
  --config /app/config.yml \
  --params /app/global-params.json \
  --finality-providers /app/finality-providers.json
```

This approach is recommended for production environments as it provides better
isolation and simplified deployment.

### Method B: Local Binary Execution

#### 1. Clone the Repository
```bash
git clone https://github.com/babylonlabs-io/staking-api-service.git
```

#### 2. Check Out the Desired Version
You can find the latest release
[here](https://github.com/babylonlabs-io/staking-api-service/releases).

```bash
cd staking-api-service
git checkout tags/{VERSION}
```

#### 3. Install the Binary
```bash
make install
```
This command will build and install the binary to your GOPATH.

#### 4. Start the Staking API Service
You can start the Staking API Service by running:

```bash
staking-api-service --config ~/.staking-api-service/config.yml \
--params ~/.staking-api-service/global-params.json \
--finality-providers ~/.staking-api-service/finality-providers.json
```

## Create Systemd Service (Linux Only)

#### 1. Create Systemd Service Definition
Run the following command, replacing `system_username` with the appropriate
system user or service account name:

```bash
cat <<EOF | sudo tee /etc/systemd/system/staking-api-service.service
[Unit]
Description=Staking API Service
After=network.target

[Service]
Type=simple
ExecStart=$(which staking-api-service) \
          --config /home/system_username/.staking-api-service/config.yml \
          --params /home/system_username/.staking-api-service/global-params.json \
          --finality-providers /home/system_username/.staking-api-service/finality-providers.json
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
sudo systemctl enable staking-api-service.service
```

#### 4. Start the Service
```bash
sudo systemctl start staking-api-service.service
```

#### 5. Verify the Service
Check service status:
```bash
sudo systemctl status staking-api-service.service
```

Expected log output:
```
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"debug","time":"2024-07-04T03:36:05Z","message":"Index created successfully on collection: unbonding_queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","time":"2024-07-04T03:36:05Z","message":"Collections and Indexes created successfully."}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","queueName":"active_staking_queue","time":"2024-07-04T03:36:05Z","message":"start receiving messages from queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","queueName":"expired_staking_queue","time":"2024-07-04T03:36:05Z","message":"start receiving messages from queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","queueName":"unbonding_staking_queue","time":"2024-07-04T03:36:05Z","message":"start receiving messages from queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","queueName":"withdraw_staking_queue","time":"2024-07-04T03:36:05Z","message":"start receiving messages from queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","queueName":"staking_stats_queue","time":"2024-07-04T03:36:05Z","message":"start receiving messages from queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","queueName":"btc_info_queue","time":"2024-07-04T03:36:05Z","message":"start receiving messages from queue"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","time":"2024-07-04T03:36:05Z","message":"Initiated Health Check Cron"}
Jul 04 03:36:05 system_username staking-api-service[824224]: {"level":"info","time":"2024-07-04T03:36:05Z","message":"Starting server on 0.0.0.0:8092"}
```

## Monitoring

The service exposes Prometheus metrics through a Prometheus server. By default,
it is available at the address configured in the metrics configuration section
(0.0.0.0:2112). Configure the metrics endpoint in your configuration file as
needed.