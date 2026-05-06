# GCP Benchmark Client - Ubuntu 24.04 c2-standard-16

This Terraform configuration deploys a Google Cloud Platform benchmark client instance equivalent to AWS c7i.4xlarge for performance testing.

## Instance Specifications

- **Machine Type**: c2-standard-16 (16 vCPUs, 64 GB RAM)
- **OS**: Ubuntu 24.04 LTS
- **Disk**: 256 GB SSD persistent disk
- **Network**: Default VPC with ephemeral public IP

## Equivalent AWS Instance

This GCP configuration is equivalent to:
- AWS c7i.4xlarge (16 vCPUs, 32 GB RAM)
- The GCP instance has more RAM (64 GB vs 32 GB) for better performance

## Pre-installed Tools

The instance comes pre-configured with:
- **redis-cli** - Redis command line interface
- **memtier_benchmark** - Redis/Memcached benchmarking tool
- **redis-benchmarks-specification** - Redis benchmarking framework
- **Docker** - Container runtime
- **Python 3** with pip

## Usage

### Deploy the instance:
```bash
terraform init
terraform plan
terraform apply
```

### Connect via SSH:
```bash
ssh -i /tmp/benchmarks.redislabs.pem ubuntu@<PUBLIC_IP>
```

### Run benchmarks:
```bash
# Test Redis connectivity
redis-cli -h <REDIS_HOST> -p <REDIS_PORT> ping

# Run memtier benchmark
memtier_benchmark -s <REDIS_HOST> -p <REDIS_PORT> -t 4 -c 50

# Run redis-benchmarks-specification
redis-benchmarks-spec-client-runner --help
```

## Firewall Configuration

The configuration automatically creates a firewall rule allowing SSH access (port 22) from any IP address. The rule is tagged to only apply to instances with the "benchmark-client" tag.

## Cleanup

```bash
terraform destroy
```

## Variables

Key variables you can customize:
- `project_id`: GCP project ID (default: "your-gcp-project")
- `region`: GCP region (default: "us-central1")
- `zone`: GCP zone (default: "us-central1-a")
- `machine_type`: Instance type (default: "c2-standard-16")
- `boot_disk_size`: Disk size in GB (default: 256)

## Outputs

The configuration provides:
- Public and private IP addresses
- SSH connection information
- Instance metadata
- Firewall rule details
