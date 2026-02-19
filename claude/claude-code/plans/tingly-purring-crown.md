# OrbStack MCP Server Plan

## Overview
Create a standalone MCP server at `/Users/Ezra/mcp-orbstack/` that exposes Docker, kubectl, and OrbStack-specific features as MCP tools for Claude Code.

## Project Structure
```
/Users/Ezra/mcp-orbstack/
├── pyproject.toml      # uv project, depends on mcp[cli]
├── server.py           # Single-file MCP server (~800-1000 LOC)
└── .python-version     # Python 3.14
```

Single-file approach — all tools follow the same pattern (async subprocess calls), no need for multi-file complexity.

## Core Infrastructure (in server.py)

- `FastMCP("orbstack")` server instance
- `run_cmd(cmd, timeout=30)` — async subprocess helper, returns stdout or raises
- `run_json_cmd(cmd, timeout=30)` — same but parses JSON output
- All tools use `@mcp.tool()` decorator with typed parameters and docstrings

## Tools (45 total)

### OrbStack System (5)
| Tool | Command |
|------|---------|
| `orb_status` | `orbctl status` (returns Running/Stopped/Starting) |
| `orb_version` | `orbctl version` |
| `orb_config_show` | `orbctl config show` |
| `orb_config_set(key, value)` | `orbctl config set KEY VALUE` |
| `orb_doctor(fix: bool=False)` | `orbctl doctor [--fix]` |

### Linux Machine Management (11)
| Tool | Command |
|------|---------|
| `orb_list_machines` | `orbctl list --format json` |
| `orb_machine_info(name)` | `orbctl info NAME --format json` |
| `orb_create_machine(distro, name?, arch?)` | `orbctl create DISTRO [NAME] [--arch]` |
| `orb_start_machine(name)` | `orbctl start NAME` |
| `orb_stop_machine(name, force?)` | `orbctl stop NAME [--force]` |
| `orb_restart_machine(name)` | `orbctl restart NAME` |
| `orb_delete_machine(name, force?)` | `orbctl delete NAME [--force]` |
| `orb_run_command(command, machine?, user?)` | `orbctl run [-m MACHINE] [-u USER] CMD` |
| `orb_push_file(source, dest, machine?)` | `orbctl push SRC DEST [-m MACHINE]` |
| `orb_pull_file(source, dest, machine?)` | `orbctl pull SRC DEST [-m MACHINE]` |
| `orb_machine_logs(name?)` | `orbctl logs [NAME]` |

### Docker (20)
| Tool | Command |
|------|---------|
| `docker_ps(all?)` | `docker ps [--all] --format json` |
| `docker_images` | `docker images --format json` |
| `docker_logs(container, tail?, follow?)` | `docker logs CONTAINER [--tail N]` |
| `docker_inspect(target)` | `docker inspect TARGET` |
| `docker_run(image, name?, ports?, volumes?, env?, command?, detach?)` | `docker run [flags] IMAGE [CMD]` |
| `docker_exec(container, command)` | `docker exec CONTAINER CMD` |
| `docker_stop(container)` | `docker stop CONTAINER` |
| `docker_start(container)` | `docker start CONTAINER` |
| `docker_rm(container, force?)` | `docker rm CONTAINER [--force]` |
| `docker_rmi(image, force?)` | `docker rmi IMAGE [--force]` |
| `docker_pull(image)` | `docker pull IMAGE` |
| `docker_build(path, tag?, dockerfile?)` | `docker build PATH [-t TAG] [-f FILE]` |
| `docker_compose_up(path?, detach?, services?)` | `docker compose [-f] up [-d] [SVCS]` |
| `docker_compose_down(path?, volumes?)` | `docker compose [-f] down [-v]` |
| `docker_compose_ps(path?)` | `docker compose [-f] ps --format json` |
| `docker_compose_logs(path?, services?, tail?)` | `docker compose [-f] logs [SVCS]` |
| `docker_volume_ls` | `docker volume ls --format json` |
| `docker_volume_rm(name, force?)` | `docker volume rm NAME [--force]` |
| `docker_network_ls` | `docker network ls --format json` |
| `docker_system_prune(all?, volumes?)` | `docker system prune [-a] [--volumes] -f` |

### OrbStack Docker Extensions (2)
| Tool | Command |
|------|---------|
| `orb_docker_volume_clone(source, dest)` | `orbctl docker volume clone SRC DEST` |
| `orb_docker_debug(container, command?)` | `orbctl debug CONTAINER [CMD]` |

### Kubernetes (7)
| Tool | Command |
|------|---------|
| `orb_k8s_start` | `orbctl start k8s` |
| `orb_k8s_stop` | `orbctl stop k8s` |
| `kubectl_get(resource, name?, namespace?, output?)` | `kubectl get RES [NAME] [-n NS] [-o FMT]` |
| `kubectl_describe(resource, name?, namespace?)` | `kubectl describe RES [NAME] [-n NS]` |
| `kubectl_logs(pod, namespace?, container?, tail?)` | `kubectl logs POD [-n NS] [-c CTR]` |
| `kubectl_apply(file?, manifest?)` | `kubectl apply -f FILE` or pipe manifest via stdin |
| `kubectl_delete(resource, name?, namespace?, file?)` | `kubectl delete RES NAME [-n NS]` or `-f FILE` |

## Error Handling
- All subprocess calls wrapped in try/except
- Capture stderr and return it in error messages
- Timeout of 30s for quick commands, 120s for builds/pulls, 10s for status checks
- JSON parse failures fall back to raw text output

## Registration with Claude Code
```bash
claude mcp add orbstack -- uv --directory /Users/Ezra/mcp-orbstack run server.py
```

## Verification
1. `uv run server.py` — should start without errors (will wait on stdin for MCP messages)
2. `claude mcp add orbstack -- uv --directory /Users/Ezra/mcp-orbstack run server.py`
3. Start a new Claude Code session and test: `orb_status`, `docker_ps`, `orb_list_machines`
4. Test a write operation: `docker_pull("alpine")`, `orb_create_machine("ubuntu", "test-vm")`
