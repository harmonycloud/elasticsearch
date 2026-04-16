# Elasticsearch Search Engine Service

**English** | [中文](README_zh.md)

Enterprise-grade Elasticsearch search and analytics service for Kubernetes with distributed clustering, multi-role node architecture, and integrated Kibana visualization.

## Overview

Elasticsearch is a distributed, RESTful search and analytics engine capable of storing, searching, and analyzing large volumes of data at near-real-time speed. This package delivers a production-ready Elasticsearch cluster on Kubernetes, supporting real-time search, log analytics, metrics monitoring, and a wide range of other use cases.

## Features

### Core Capabilities
- **Full-text search**: Powerful full-text search with complex query syntax support
- **Real-time analytics**: Real-time data indexing and analytics with aggregation queries
- **Distributed architecture**: Automatic sharding and replica management with horizontal scaling
- **High availability**: Multi-node clustering with automatic failover and recovery
- **RESTful API**: Complete REST API for easy integration and development
- **Durable storage**: Kubernetes persistent volumes for data persistence

### Advanced Features
- **Multi-role nodes**: Support for Master, Data, Client, and Cold node roles
- **Index management**: Automatic index lifecycle management with index templates
- **Monitoring and alerting**: Integrated Prometheus metrics and alert rules
- **Kibana integration**: Built-in Kibana visualization dashboard
- **Backup and restore**: Snapshot and restore functionality
- **Security and authentication**: User authentication and access control
- **Log management**: File-based and stdout logging support

### Enterprise Features
- **Cluster management**: Automatic cluster discovery and node management
- **Load balancing**: Intelligent query routing and load distribution
- **Performance tuning**: Built-in performance optimization parameters
- **Scalability**: Dynamic node addition and removal
- **Multi-tenancy**: Index-level isolation support

## Supported Versions

### Elasticsearch Releases
- **8.14.3** (latest)
- **7.17.28**
- **7.16.2**
- **7.16.3**
- **6.8.22**

### Component Releases
- **Package version**: 1.12.1-1.0.0
- **ES Exporter**: v1.6.0
- **ES Init**: v1.7.0

## Architecture

### Deployment Modes

#### 1. Cluster (cluster)
- **Use cases**: Production environments requiring highly available search services
- **Traits**: Multi-node cluster with automatic failover
- **Topology**: 3+ Master nodes ensuring cluster stability

#### 2. Complex Cluster (complex-cluster)
- **Use cases**: Large-scale production environments requiring role separation
- **Traits**: Multi-role node separation for optimized resource usage
- **Topology**: Independent Master, Data, Client, and Cold nodes

#### 3. Cluster Active-Active (cluster-active)
- **Use cases**: Multi-site active-active deployments
- **Traits**: Cross-datacenter cluster replication

#### 4. Complex Cluster Active-Active (complex-cluster-active)
- **Use cases**: Large-scale multi-site active-active deployments with role separation
- **Traits**: Multi-role nodes with cross-datacenter replication

#### 5. Operator Standard (operator-standard)
- **Use cases**: Development, testing, and quick deployment
- **Traits**: Single-instance, minimal resources

#### 6. Operator Highly Available (operator-highly-available)
- **Use cases**: Production environments
- **Traits**: Multi-instance with automatic failover

### Technical Architecture

```
+---------------------------------------------------------+
|                  Elasticsearch Cluster                   |
+---------------------------------------------------------+
|  +-----------+  +-----------+  +-----------+            |
|  |  Master   |  |  Master   |  |  Master   |            |
|  |  Node     |  |  Node     |  |  Node     |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|  +-----------+  +-----------+  +-----------+            |
|  |  Data     |  |  Data     |  |  Data     |            |
|  |  Node     |  |  Node     |  |  Node     |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|  +-----------+  +-----------+  +-----------+            |
|  |  Client   |  |  Client   |  |  Cold     |            |
|  |  Node     |  |  Node     |  |  Node     |            |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|  +-----------+  +-----------+  +-----------+            |
|  |  Kibana   |  | Exporter  |  |  Service  |            |
|  |  Node     |  |  Node     |  | (Endpoints)|           |
|  +-----------+  +-----------+  +-----------+            |
+---------------------------------------------------------+
|               Kubernetes Storage (PVC)                  |
+---------------------------------------------------------+
```

### Node Roles

- **Master node**: Cluster management, index management, node coordination
- **Data node**: Data storage, index shards, search execution
- **Client node**: Query routing, load balancing, API gateway
- **Cold node**: Cold data storage, archive data management
- **Kibana node**: Data visualization and analytics dashboard
- **Exporter node**: Monitoring metrics collection

## Prerequisites

- Kubernetes 1.26+
- [OpenSaola Operator](https://github.com/harmonycloud/opensaola) deployed
- [saola-cli](https://github.com/harmonycloud/saola-cli) installed

## Quick Start

```bash
# Publish the package
saola publish elasticsearch/

# Install the operator
saola operator create es-operator --type Elasticsearch --version 8.14.3

# Create an instance
saola middleware create my-elasticsearch --type Elasticsearch --version 8.14.3

# Check status
saola middleware get my-elasticsearch
```

## Available Actions

| Action | Description |
|--------|-------------|
| datasecurity | Manage data security settings |

## Configuration

Key parameters can be customized via the baseline configuration. See `manifests/*parameters.yaml` for the full parameter reference:

- `manifests/clusterparameters.yaml` -- Cluster mode parameters
- `manifests/complexclusterparameters.yaml` -- Complex cluster mode parameters
- `manifests/clusteractiveparameters.yaml` -- Active-active cluster parameters
- `manifests/complexclusteractiveparameters.yaml` -- Active-active complex cluster parameters

## Usage Guidance

### Environment Selection

#### Development and Test
- **Recommended topology**: Operator Standard
- **Resources**: CPU 1 core, memory 4 Gi, storage 50 Gi
- **Suggested version**: Elasticsearch 7.16.3
- **Instances**: 3 Master nodes

#### Production
- **Recommended topology**: Complex Cluster
- **Resources**:
  - Master: CPU 2+ cores, memory 8+ Gi
  - Data: CPU 4+ cores, memory 16+ Gi, storage 500+ Gi
  - Client: CPU 2+ cores, memory 8+ Gi
- **Suggested version**: Elasticsearch 8.14.3 or 7.17.28
- **Instances**: 3+ nodes for high availability

### Best Practices

#### Security
- Enforce strong passwords with mixed character classes
- Enable SSL connection encryption
- Rotate database credentials periodically
- Configure appropriate access control rules
- Enable audit logging for sensitive operations

#### Performance Tuning
- Adjust `heap_size` based on data volume (recommend no more than 50% of physical memory)
- Configure appropriate `number_of_shards` and `number_of_replicas`
- Enable slow query logging for performance analysis
- Use proper index templates and mappings
- Optimize queries and aggregation operations

#### Index Management
- Use Index Lifecycle Management (ILM)
- Set appropriate index templates
- Regularly clean expired indices
- Monitor index sizes and shard counts
- Use aliases for index management

#### Monitoring and Alerting
- Track cluster health status, node status, and index status
- Define alert thresholds for critical metrics
- Review slow query logs routinely
- Monitor disk usage and JVM memory usage
- Watch search performance and indexing throughput

## Related Projects

| Project | Description |
|---------|-------------|
| [OpenSaola Operator](https://github.com/harmonycloud/opensaola) | Core Kubernetes operator for middleware lifecycle management |
| [saola-cli](https://github.com/harmonycloud/saola-cli) | Command-line tool for middleware management |
| [PostgreSQL](https://github.com/harmonycloud/postgresql) | PostgreSQL database package |
| [MySQL](https://github.com/harmonycloud/mysql) | MySQL database package |
| [Kafka](https://github.com/harmonycloud/kafka) | Apache Kafka streaming platform package |
| [Redis](https://github.com/harmonycloud/redis) | Redis in-memory data store package |
| [ZooKeeper](https://github.com/harmonycloud/zookeeper) | Apache ZooKeeper coordination service package |
| [RabbitMQ](https://github.com/harmonycloud/rabbitmq) | RabbitMQ message broker package |

## License

This project is licensed under the [Apache License 2.0](LICENSE).
