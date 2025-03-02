# Babylon Staking Indexer

The Babylon Staking Indexer is a tool that extracts staking-relevant data from both the Babylon blockchain and the Bitcoin blockchain. It processes, validates, and stores staking transactions—ensuring they adhere to valid staking prerequisites—and determines whether stakes should be active. All valid staking transactions are transformed into a structured format, stored in a MongoDB database, and published as events in a RabbitMQ messaging queue for consumption. This indexer serves as the ground truth for the Bitcoin Staking system, enforcing the Bitcoin Staking protocol.

## 1. Hardware Requirements

- **CPU:** Multi-core processor (4 cores minimum)
- **Memory:** Minimum 8GB RAM (recommended 16GB RAM)
- **Storage:** Sufficient space for MongoDB data (at least 10GB recommended)

## 2. Install Babylon Staking Indexer

### 2.1 Clone the Repository
Clone the repository to your local machine from GitHub:
```bash
git clone https://github.com/babylonlabs-io/babylon-staking-indexer.git
```

### 2.2 Check Out the Desired Version
Check out the desired version. You can find the latest release [here](#).

### 2.3 Install the Binary
Install the babylon-staking-indexer binary by running:
```bash
make install
```
This command will build and install the binary to your GOPATH.

## 3. Configuration

### 3.1 Create a Configuration File
Create a `config.yml` file in your home directory. Default locations:
- **MacOS/Linux:** `~/config.yml`
- **Windows:** `C:\Users\<username>\config.yml`

You can use the provided sample configuration files as a template.

### 3.2 Update Configuration Settings
Edit the `config.yml` file to match your environment:
- **MongoDB Connection:** indexer
- **Bitcoin Node Connection:** needed
- **Babylon Node Connection:** 500ms
- **RabbitMQ Configuration:** quorum
- **Prometheus Metrics Configuration:** 2112

## 4. Start Babylon Staking Indexer

### 4.1 Start the Indexer
Start the indexer with your configuration file:
```bash
./babylon-staking-indexer --config config.yml
```
Alternatively, use the provided script to run locally:
```bash
./run-local.sh
```
This uses the local configuration file at `config/config-local.yml`.

## 5. Create systemd Service (Optional - Linux Only)

### 5.1 Create a systemd Service Definition
Create a service file (e.g., `/etc/systemd/system/babylon-staking-indexer.service`) with the appropriate configuration. Replace `system_username` with the correct system user or service account.

### 5.2 Reload systemd Configuration
```bash
sudo systemctl daemon-reload
```

### 5.3 Enable the Service at Boot
```bash
sudo systemctl enable babylon-staking-indexer
```

### 5.4 Start the Service
```bash
sudo systemctl start babylon-staking-indexer
```

### 5.5 Verify the Service
Check the status to ensure the indexer is running:
```bash
sudo systemctl status babylon-staking-indexer
```
(Expected log output will confirm the service is active.)

## 6. Docker Deployment (Alternative)

### 6.1 Build the Docker Image
```bash
docker build -t babylon-staking-indexer .
```

### 6.2 Start the Service with Docker
```bash
docker run -d --name staking-indexer \
  -v $(pwd)/config.yml:/app/config.yml \
  babylonlabs/babylon-staking-indexer:latest --config /app/config.yml
```

### 6.3 Stop the Docker Container
```bash
docker stop staking-indexer
```

## 7. Monitoring

The service exposes Prometheus metrics through a Prometheus server. By default, it is available at `0.0.0.0:2112`. Configure the metrics endpoint in your `config.yml` file as needed.

## 8. Troubleshooting

### 8.1 Connection Issues with Babylon Node
- Verify that the Babylon node is running and accessible.
- Check the `rpc-addr` in your configuration file.
- Ensure network connectivity between the indexer and the Babylon node.

### 8.2 Connection Issues with Bitcoin Node
- Verify that the Bitcoin node is running and accessible.
- Check the `rpchost`, `rpcuser`, and `rpcpass` in your configuration file.
- Ensure network connectivity between the indexer and the Bitcoin node.

### 8.3 MongoDB Connection Issues
- Ensure MongoDB is running with replica set enabled.
- Verify the MongoDB connection string in your configuration file.
- Check network connectivity between the indexer and MongoDB.

### 8.4 RabbitMQ Connection Issues
- Verify that RabbitMQ is running and accessible.
- Check the RabbitMQ connection details in your configuration file.
- Ensure network connectivity between the indexer and RabbitMQ.