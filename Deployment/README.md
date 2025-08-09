# OpenClone Deployment Options

## Overview

OpenClone supports two deployment approaches: cloud-based Kubernetes clusters via Vultr, and self-hosting on local hardware.

## Option 1: Vultr Kubernetes (IAC)

Deploy OpenClone to Vultr's Cloud!

**Problem**: Vultr requires you to leave a GPU node running at all times and limits the number of times you can create/destroy nodes. While the `/IAC` project does work, the limits imposed by Vultr make work difficult. If you want to pay them to leave a GPU node on at all times, it will work. The cost for a GPU node that is good enough to run OpenClone was at most $250/month as of August 2025, however the minimum cost could not be found due to their arbitrary limits (and my patience).

- See [IAC/README.md](IAC/README.md) for implementation details.
- See [OpenClone-DevContainer-StatusBar/README.md](IAC/README.md) for the OpenClone VS Code extension used by the `/IAC` project.

## Option 2: Self-Hosting

Self-host and save $$$.

**Solution**: Just self-host it. See [Serverless-0/README.md](Serverless-0/README.md) for details.
