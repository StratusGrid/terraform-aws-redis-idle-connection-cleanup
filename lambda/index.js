
"use strict";

const async = require("async");
const redis = require("ioredis");
const { ElastiCacheClient, DescribeCacheClustersCommand } = require("@aws-sdk/client-elasticache");

const idleThresholdSeconds = process.env.IDLE_THRESHOLD_SECONDS ? process.env.IDLE_THRESHOLD_SECONDS : 86400; // one day
const concurrentRequestsLimit = process.env.CONCURRENT_REQUEST_LIMIT ? process.env.CONCURRENT_REQUEST_LIMIT : 50;
const dry_run = process.env.DRY_RUN ? process.env.DRY_RUN == "true" : false;
const region = process.env.REGION ? process.env.REGION : "us-west-2";

async function main(event, context) {
    if (dry_run) {
        console.log("Running in dry run mode");
    }

    const nodes = await getRedisCacheEndpoints();

    for (const node of nodes) {
        let redisClient;

        try {
            console.log(`Connecting to: ${node.Address}`);
            redisClient = new redis(node.Port, node.Address, { maxRetriesPerRequest: 1 });

            const clients = await getConnectedClients(redisClient);
            console.log(`Total Connected Clients: ${clients.length}`);

            const idleClients = clients.filter(client => client.idle > parseInt(idleThresholdSeconds));
            console.log(`Total Clients Over ${idleThresholdSeconds} Seconds Idle Threshold: ${idleClients.length}`);

            await closeIdleConnections(redisClient, idleClients);
        } catch (error) {
            console.log("Some error happened");
            console.log(error);
        } finally {
            if (redisClient) {
                console.log(`Closing connection to ${node.Address}`);
                redisClient.quit();
            }
        }
    }
}

async function closeIdleConnections(redisClient, idleClients) {
    return async.mapLimit(idleClients, concurrentRequestsLimit, async (idleClient) => {
        try {
            if (!dry_run) {
                if (idleClient.addr) {
                    await redisClient.client("kill", idleClient.addr);
                    console.log(`Successfully closed connection: ${idleClient.addr} on ${redisClient.options.host} - idle for ${idleClient.idle}`);
                } else {
                    console.log(`Client missing addr attribute:`);
                    console.log(idleClient);
                }
            } else {
                console.log(`Skipped closing connection: ${idleClient.addr} due to dry_run mode - idle for ${idleClient.idle}`);
            }
        } catch (error) {
            // Log connection that threw error
            console.log(`Error closing connection: ${idleClient.addr}`);

            // Rethrow error, gets rolled up by mapLimit for the currently executing batch
            throw error;
        }
    });
}

async function getConnectedClients(redisClient) {
    let clientListRes = await redisClient.client("list");
    clientListRes = clientListRes.trim();

    const clients = [];
    const rows = clientListRes.split("\n");

    rows.forEach((row) => {
        const client = {};
        const attributes = row.split(" ");

        attributes.forEach((attribute) => {
            const kvp = attribute.split("=");
            if (kvp.length == 2) {
                client[kvp[0]] = kvp[1];
            }
        })

        if (Object.keys(client).length > 0) {
            // Only adding client if attributes were found
            clients.push(client);
        }
    })

    return clients;
}

async function getRedisCacheEndpoints() {
    const client = new ElastiCacheClient({ region: region });
    const params = {
        ShowCacheNodeInfo: true,
    };
    const command = new DescribeCacheClustersCommand(params);

    const response = await client.send(command);
    console.log(`Total Elasticache Nodes: ${response.CacheClusters.length}`);

    let nodeConnectionInfo = [];

    for (const cluster of response.CacheClusters) {
        if (cluster.Engine == "redis") {
            cluster.CacheNodes.forEach((node) => {
                nodeConnectionInfo.push(node.Endpoint);
            });
        }
    }

    console.log(`Total Redis Elasticache Nodes: ${nodeConnectionInfo.length}`);

    return nodeConnectionInfo;
}

async function lambda_handler() {
    await main()
        .catch((err) => {
            console.error(err);
            throw new Error(`Execution Error: See Logs for More Details: ${err}`);
        });
    return "ok";
}

exports.lambda_handler = lambda_handler;

lambda_handler();
