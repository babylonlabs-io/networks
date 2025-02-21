# Staking API

The Staking API Service is a critical component of the Babylon Phase-2 system, focused on serving information about the state of the network and receiving unbonding requests for further processing. The API can be utilised by user facing applications, such as staking dApps.

## Hardware Requirements

- CPU: Multi-core processor (4 cores minimum)
- Memory: Minimum 4GB RAM, recommended 8GB RAM

## Installation

### 1. Clone the repository

2.1 Clone the repository to your local machine from Github
```bash
git clone git@github.com:babylonlabs-io/staking-api-service.git
```

2.2 Check out the desired version
You can find the latest release [here](https://github.com/babylonlabs-io/staking-api-service/releases).

```bash
cd staking-api-service
git checkout tags/{VERSION}
```

2.3 Install the binary by running
```bash
make install
```

### 3. Configuration

3.1 Create home directory
```bash
mkdir -p ~/.staking-api-service/
```

3.2 Copy the default configuration
```bash
cp ~/staking-api-service/config/config-local.yml ~/.staking-api-service/config.yml
```

3.3 Update default configurations
MongoDB cluster to connect to
Set the MongoDB connection address (`address`) and credentials (`username`, `password`, and `db-name`) to match the information from the [installed MongoDB cluster](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/infra/mongodb).

```bash
db:
  address: "mongodb://localhost:27017/?directConnection=true"
  username: "<username>"
  password: "<password>"
  db-name: "<db-name>"
```

RabbitMQ cluster to connect to
Set the RabbitMQ connection address (`url`) and credentials (`queue_user` and `queue_password`) to match the information from the [installed RabbitMQ cluster](https://docs.babylonlabs.io/docs/user-guides/bitcoin-staking-phase1/backend-deployment/infra/rabbitmq).

```bash
queue:
  queue_user: admin
  queue_password: password
  url: "localhost:5672"
```

Prometheus metrics configuration:
Set the host and port to customize how the metrics are exposed

```bash
metrics:
  host: 0.0.0.0
  port: 2112
```

4. Start Staking API
You can start the Staking API by running:

```bash
staking-api-service --config ~/.staking-api-service/config.yml
```

5. Create systemd service (Optional - Linux Only)
7.1 Create systemd service definition
Run the following command, replacing `system_username` with the appropriate system user or service account name:

```bash
cat <<EOF | sudo tee /etc/systemd/system/staking-api.service
[Unit]
Description=Staking API service
After=network.target

[Service]
Type=simple
ExecStart=$(which staking-api-service)  \
          --config /home/system_username/.staking-api-service/config.yml
Restart=on-failure
User=system_username

[Install]
WantedBy=multi-user.target
EOF
```

7.2 Reload systemd manager configuration
```bash
sudo systemctl daemon-reload
```

7.3 Enable the service to start on boot
```bash
sudo systemctl enable staking-api.service
```

7.4 Start the service
```bash
sudo systemctl start staking-api.service
```

7.5. Verify Staking API is running
Check staking-api service status:

```bash
sudo systemctl status staking-api
```

Expected log:

```bash
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

### 8. Monitoring

The service exposes Prometheus metrics through a Prometheus server. By default, the server is reachable under `127.0.0.1:2112`.