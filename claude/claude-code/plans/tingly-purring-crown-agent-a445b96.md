# OrbStack MCP Server Implementation Plan

## Project Overview

A standalone Python MCP server that integrates OrbStack, Docker, and Kubernetes functionality into Claude Code through the Model Context Protocol. This will provide seamless container and VM management capabilities directly from Claude.

## 1. Project Structure

### Recommended Structure: Single File Approach

```
/Users/Ezra/mcp-orbstack/
├── pyproject.toml          # Project metadata and dependencies
├── README.md               # Documentation and setup instructions
├── .gitignore              # Git ignore file
├── .python-version         # Python version (3.14)
└── server.py               # Main MCP server implementation (single file)
```

**Rationale for Single File:**
- The server is essentially a collection of CLI wrappers with minimal shared logic
- Total implementation ~800-1000 lines of code (manageable in one file)
- FastMCP class encourages simple, straightforward implementations
- Easier to deploy and maintain for a single-purpose server
- All tools follow similar patterns (async subprocess execution)

### Alternative Multi-File Structure (if complexity grows):

```
/Users/Ezra/mcp-orbstack/
├── pyproject.toml
├── README.md
├── .gitignore
├── .python-version
└── mcp_orbstack/
    ├── __init__.py
    ├── server.py           # Main FastMCP server and tool registration
    ├── orbstack.py         # OrbStack-specific tools
    ├── docker.py           # Docker tools
    ├── kubernetes.py       # Kubernetes tools
    └── utils.py            # Shared utilities (subprocess wrapper, error handling)
```

**Decision: Start with single file, refactor if it exceeds 1200 lines.**

## 2. Dependencies (pyproject.toml)

```toml
[project]
name = "mcp-orbstack"
version = "0.1.0"
description = "MCP server for OrbStack, Docker, and Kubernetes integration"
readme = "README.md"
requires-python = ">=3.14"
dependencies = [
    "mcp>=1.0.0",
]

[project.scripts]
mcp-orbstack = "server:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

## 3. Core Implementation Architecture

### 3.1 Base Server Setup (FastMCP)

```python
from mcp import FastMCP
import asyncio
import subprocess
import json
from typing import Optional, Dict, Any, List

# Initialize FastMCP server
mcp = FastMCP("OrbStack")

async def run_command(
    cmd: List[str],
    check: bool = True,
    capture_output: bool = True,
    text: bool = True,
    timeout: Optional[int] = 30
) -> subprocess.CompletedProcess:
    """
    Execute a command asynchronously using subprocess.
    
    Args:
        cmd: Command and arguments as list
        check: Raise exception on non-zero exit
        capture_output: Capture stdout/stderr
        text: Return output as text (not bytes)
        timeout: Command timeout in seconds
        
    Returns:
        CompletedProcess with stdout, stderr, returncode
        
    Raises:
        subprocess.CalledProcessError: If check=True and command fails
        subprocess.TimeoutExpired: If command exceeds timeout
    """
    process = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE if capture_output else None,
        stderr=asyncio.subprocess.PIPE if capture_output else None,
    )
    
    try:
        stdout, stderr = await asyncio.wait_for(
            process.communicate(),
            timeout=timeout
        )
        
        if text:
            stdout = stdout.decode('utf-8') if stdout else ""
            stderr = stderr.decode('utf-8') if stderr else ""
            
        if check and process.returncode != 0:
            raise subprocess.CalledProcessError(
                process.returncode, cmd, stdout, stderr
            )
            
        # Create a compatible return object
        result = type('CompletedProcess', (), {
            'returncode': process.returncode,
            'stdout': stdout,
            'stderr': stderr,
            'args': cmd
        })()
        
        return result
        
    except asyncio.TimeoutError:
        process.kill()
        await process.wait()
        raise subprocess.TimeoutExpired(cmd, timeout)

async def run_json_command(
    cmd: List[str],
    timeout: Optional[int] = 30
) -> Dict[str, Any]:
    """
    Run a command that outputs JSON and parse the result.
    
    Args:
        cmd: Command that outputs JSON
        timeout: Command timeout
        
    Returns:
        Parsed JSON as dict
    """
    result = await run_command(cmd, timeout=timeout)
    return json.loads(result.stdout)
```

### 3.2 Error Handling Strategy

```python
from functools import wraps
from typing import Callable

def handle_errors(func: Callable) -> Callable:
    """
    Decorator to handle common errors in MCP tools.
    Converts exceptions to user-friendly error messages.
    """
    @wraps(func)
    async def wrapper(*args, **kwargs):
        try:
            return await func(*args, **kwargs)
        except subprocess.CalledProcessError as e:
            error_msg = e.stderr.strip() if e.stderr else str(e)
            return f"Error: Command failed with exit code {e.returncode}\n{error_msg}"
        except subprocess.TimeoutExpired as e:
            return f"Error: Command timed out after {e.timeout} seconds"
        except json.JSONDecodeError as e:
            return f"Error: Failed to parse JSON output: {e}"
        except FileNotFoundError as e:
            return f"Error: Command not found. Is OrbStack/Docker/kubectl installed?"
        except Exception as e:
            return f"Error: Unexpected error: {type(e).__name__}: {e}"
    return wrapper
```

## 4. Tool Implementation Categories

### 4.1 OrbStack System Tools

```python
@mcp.tool()
@handle_errors
async def orb_status() -> str:
    """Check if OrbStack is running."""
    result = await run_command(["orbctl", "status"])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_version() -> str:
    """Get OrbStack version information."""
    result = await run_command(["orbctl", "version"])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_config_show() -> str:
    """Show current OrbStack configuration."""
    result = await run_command(["orbctl", "config", "show"])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_config_set(key: str, value: str) -> str:
    """
    Set an OrbStack configuration option.
    
    Args:
        key: Configuration key (e.g., 'docker.set_context')
        value: Value to set
    """
    result = await run_command(["orbctl", "config", "set", key, value])
    return result.stdout.strip() or f"Set {key} = {value}"

@mcp.tool()
@handle_errors
async def orb_doctor() -> str:
    """Run OrbStack diagnostics to check configuration."""
    result = await run_command(["orbctl", "doctor"])
    return result.stdout.strip()
```

### 4.2 Linux Machine Management Tools

```python
@mcp.tool()
@handle_errors
async def orb_list_machines(format: str = "text", running_only: bool = False) -> str:
    """
    List all OrbStack machines.
    
    Args:
        format: Output format - 'text' or 'json' (default: text)
        running_only: Show only running machines (default: false)
    """
    cmd = ["orbctl", "list", "--format", format]
    if running_only:
        cmd.append("--running")
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_machine_info(machine: str, format: str = "text") -> str:
    """
    Get detailed information about a specific machine.
    
    Args:
        machine: Machine name or ID
        format: Output format - 'text' or 'json' (default: text)
    """
    result = await run_command(["orbctl", "info", machine, "--format", format])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_create_machine(
    distro: str,
    name: Optional[str] = None,
    version: Optional[str] = None,
    arch: Optional[str] = None,
    user: Optional[str] = None
) -> str:
    """
    Create a new Linux machine.
    
    Args:
        distro: Distribution name (ubuntu, fedora, debian, arch, alpine, etc.)
        name: Optional machine name
        version: Optional distribution version (latest if not specified)
        arch: CPU architecture - 'arm64' or 'amd64' (default: current)
        user: Username for the default user
    """
    distro_spec = f"{distro}:{version}" if version else distro
    cmd = ["orbctl", "create"]
    
    if arch:
        cmd.extend(["--arch", arch])
    if user:
        cmd.extend(["--user", user])
    
    cmd.append(distro_spec)
    if name:
        cmd.append(name)
    
    result = await run_command(cmd, timeout=120)  # Longer timeout for creation
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_start_machine(machine: str) -> str:
    """
    Start a stopped machine.
    
    Args:
        machine: Machine name or ID
    """
    result = await run_command(["orbctl", "start", machine])
    return result.stdout.strip() or f"Started machine: {machine}"

@mcp.tool()
@handle_errors
async def orb_stop_machine(machine: str) -> str:
    """
    Stop a running machine.
    
    Args:
        machine: Machine name or ID
    """
    result = await run_command(["orbctl", "stop", machine])
    return result.stdout.strip() or f"Stopped machine: {machine}"

@mcp.tool()
@handle_errors
async def orb_restart_machine(machine: str) -> str:
    """
    Restart a machine.
    
    Args:
        machine: Machine name or ID
    """
    result = await run_command(["orbctl", "restart", machine])
    return result.stdout.strip() or f"Restarted machine: {machine}"

@mcp.tool()
@handle_errors
async def orb_delete_machine(machine: str) -> str:
    """
    Delete a machine permanently.
    
    Args:
        machine: Machine name or ID
    """
    result = await run_command(["orbctl", "delete", machine, "--force"])
    return result.stdout.strip() or f"Deleted machine: {machine}"

@mcp.tool()
@handle_errors
async def orb_run_command(
    command: str,
    machine: Optional[str] = None,
    user: Optional[str] = None
) -> str:
    """
    Run a command on a Linux machine.
    
    Args:
        command: Command to execute
        machine: Machine name (default machine if not specified)
        user: User to run as (default user if not specified)
    """
    cmd = ["orbctl", "run"]
    if machine:
        cmd.extend(["--machine", machine])
    if user:
        cmd.extend(["--user", user])
    
    # Split command for proper subprocess handling
    cmd.extend(command.split())
    
    result = await run_command(cmd, timeout=60)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def orb_push_file(source: str, destination: str, machine: Optional[str] = None) -> str:
    """
    Copy files from macOS to a Linux machine.
    
    Args:
        source: Source path on macOS
        destination: Destination path on Linux
        machine: Target machine (default machine if not specified)
    """
    cmd = ["orbctl", "push"]
    if machine:
        cmd.extend(["--machine", machine])
    cmd.extend([source, destination])
    
    result = await run_command(cmd, timeout=120)
    return result.stdout.strip() or f"Pushed {source} to {destination}"

@mcp.tool()
@handle_errors
async def orb_pull_file(source: str, destination: str, machine: Optional[str] = None) -> str:
    """
    Copy files from a Linux machine to macOS.
    
    Args:
        source: Source path on Linux
        destination: Destination path on macOS
        machine: Source machine (default machine if not specified)
    """
    cmd = ["orbctl", "pull"]
    if machine:
        cmd.extend(["--machine", machine])
    cmd.extend([source, destination])
    
    result = await run_command(cmd, timeout=120)
    return result.stdout.strip() or f"Pulled {source} to {destination}"
```

### 4.3 Docker Tools

```python
@mcp.tool()
@handle_errors
async def docker_ps(all: bool = False) -> str:
    """
    List Docker containers.
    
    Args:
        all: Show all containers (default shows just running)
    """
    cmd = ["docker", "ps"]
    if all:
        cmd.append("--all")
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_images() -> str:
    """List Docker images."""
    result = await run_command(["docker", "images"])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_logs(container: str, tail: Optional[int] = None, follow: bool = False) -> str:
    """
    Get logs from a container.
    
    Args:
        container: Container name or ID
        tail: Number of lines to show from the end
        follow: Follow log output (stream mode)
    """
    cmd = ["docker", "logs"]
    if tail:
        cmd.extend(["--tail", str(tail)])
    if follow:
        cmd.append("--follow")
    cmd.append(container)
    
    timeout = None if follow else 30
    result = await run_command(cmd, timeout=timeout)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_inspect(container: str) -> str:
    """
    Get detailed information about a container in JSON format.
    
    Args:
        container: Container name or ID
    """
    result = await run_command(["docker", "inspect", container])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_run(
    image: str,
    name: Optional[str] = None,
    detach: bool = True,
    ports: Optional[str] = None,
    env: Optional[str] = None,
    volumes: Optional[str] = None,
    command: Optional[str] = None
) -> str:
    """
    Run a new container.
    
    Args:
        image: Docker image to run
        name: Container name
        detach: Run in background (default: true)
        ports: Port mappings (e.g., "8080:80")
        env: Environment variables (e.g., "KEY=value")
        volumes: Volume mounts (e.g., "/host:/container")
        command: Command to run in container
    """
    cmd = ["docker", "run"]
    if detach:
        cmd.append("-d")
    if name:
        cmd.extend(["--name", name])
    if ports:
        for port in ports.split(","):
            cmd.extend(["-p", port.strip()])
    if env:
        for e in env.split(","):
            cmd.extend(["-e", e.strip()])
    if volumes:
        for vol in volumes.split(","):
            cmd.extend(["-v", vol.strip()])
    
    cmd.append(image)
    if command:
        cmd.extend(command.split())
    
    result = await run_command(cmd, timeout=120)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_exec(container: str, command: str, interactive: bool = False) -> str:
    """
    Execute a command in a running container.
    
    Args:
        container: Container name or ID
        command: Command to execute
        interactive: Allocate a TTY
    """
    cmd = ["docker", "exec"]
    if interactive:
        cmd.append("-it")
    cmd.append(container)
    cmd.extend(command.split())
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_stop(container: str) -> str:
    """
    Stop a running container.
    
    Args:
        container: Container name or ID
    """
    result = await run_command(["docker", "stop", container])
    return result.stdout.strip() or f"Stopped container: {container}"

@mcp.tool()
@handle_errors
async def docker_rm(container: str, force: bool = False) -> str:
    """
    Remove a container.
    
    Args:
        container: Container name or ID
        force: Force removal of running container
    """
    cmd = ["docker", "rm"]
    if force:
        cmd.append("--force")
    cmd.append(container)
    
    result = await run_command(cmd)
    return result.stdout.strip() or f"Removed container: {container}"

@mcp.tool()
@handle_errors
async def docker_rmi(image: str, force: bool = False) -> str:
    """
    Remove an image.
    
    Args:
        image: Image name or ID
        force: Force removal
    """
    cmd = ["docker", "rmi"]
    if force:
        cmd.append("--force")
    cmd.append(image)
    
    result = await run_command(cmd)
    return result.stdout.strip() or f"Removed image: {image}"

@mcp.tool()
@handle_errors
async def docker_pull(image: str) -> str:
    """
    Pull an image from a registry.
    
    Args:
        image: Image name (e.g., "nginx:latest")
    """
    result = await run_command(["docker", "pull", image], timeout=300)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_build(
    path: str,
    tag: Optional[str] = None,
    dockerfile: Optional[str] = None,
    build_args: Optional[str] = None
) -> str:
    """
    Build an image from a Dockerfile.
    
    Args:
        path: Build context path
        tag: Image tag (e.g., "myapp:latest")
        dockerfile: Path to Dockerfile (default: Dockerfile in path)
        build_args: Build arguments (e.g., "ARG1=val1,ARG2=val2")
    """
    cmd = ["docker", "build"]
    if tag:
        cmd.extend(["-t", tag])
    if dockerfile:
        cmd.extend(["-f", dockerfile])
    if build_args:
        for arg in build_args.split(","):
            cmd.extend(["--build-arg", arg.strip()])
    cmd.append(path)
    
    result = await run_command(cmd, timeout=600)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_compose_up(
    file: Optional[str] = None,
    detach: bool = True,
    build: bool = False
) -> str:
    """
    Start services defined in docker-compose.yml.
    
    Args:
        file: Path to compose file (default: docker-compose.yml)
        detach: Run in background
        build: Build images before starting
    """
    cmd = ["docker", "compose"]
    if file:
        cmd.extend(["-f", file])
    cmd.append("up")
    if detach:
        cmd.append("-d")
    if build:
        cmd.append("--build")
    
    result = await run_command(cmd, timeout=300)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_compose_down(file: Optional[str] = None, volumes: bool = False) -> str:
    """
    Stop and remove containers defined in docker-compose.yml.
    
    Args:
        file: Path to compose file
        volumes: Remove named volumes
    """
    cmd = ["docker", "compose"]
    if file:
        cmd.extend(["-f", file])
    cmd.append("down")
    if volumes:
        cmd.append("--volumes")
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_compose_ps(file: Optional[str] = None) -> str:
    """
    List containers for docker-compose services.
    
    Args:
        file: Path to compose file
    """
    cmd = ["docker", "compose"]
    if file:
        cmd.extend(["-f", file])
    cmd.append("ps")
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_compose_logs(
    file: Optional[str] = None,
    service: Optional[str] = None,
    tail: Optional[int] = None
) -> str:
    """
    View output from docker-compose services.
    
    Args:
        file: Path to compose file
        service: Specific service name
        tail: Number of lines to show
    """
    cmd = ["docker", "compose"]
    if file:
        cmd.extend(["-f", file])
    cmd.append("logs")
    if tail:
        cmd.extend(["--tail", str(tail)])
    if service:
        cmd.append(service)
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_volume_ls() -> str:
    """List Docker volumes."""
    result = await run_command(["docker", "volume", "ls"])
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def docker_network_ls() -> str:
    """List Docker networks."""
    result = await run_command(["docker", "network", "ls"])
    return result.stdout.strip()
```

### 4.4 OrbStack Docker Extensions

```python
@mcp.tool()
@handle_errors
async def orb_docker_volume_clone(source: str, destination: str) -> str:
    """
    Clone a Docker volume (OrbStack extension).
    
    Args:
        source: Source volume name
        destination: Destination volume name
    """
    result = await run_command(
        ["orbctl", "docker", "volume", "clone", source, destination],
        timeout=300
    )
    return result.stdout.strip() or f"Cloned volume {source} to {destination}"

@mcp.tool()
@handle_errors
async def orb_docker_debug(container: str, command: Optional[str] = None) -> str:
    """
    Debug a Docker container with extra tools (Pro feature).
    
    Args:
        container: Container name or ID
        command: Command to run in debug shell
    """
    cmd = ["orbctl", "debug", container]
    if command:
        cmd.extend(command.split())
    
    result = await run_command(cmd, timeout=60)
    return result.stdout.strip()
```

### 4.5 Kubernetes Tools

```python
@mcp.tool()
@handle_errors
async def orb_k8s_start() -> str:
    """Start the OrbStack Kubernetes cluster."""
    result = await run_command(["orbctl", "start", "k8s"], timeout=120)
    return result.stdout.strip() or "Kubernetes cluster started"

@mcp.tool()
@handle_errors
async def orb_k8s_stop() -> str:
    """Stop the OrbStack Kubernetes cluster."""
    result = await run_command(["orbctl", "stop", "k8s"])
    return result.stdout.strip() or "Kubernetes cluster stopped"

@mcp.tool()
@handle_errors
async def kubectl_get(
    resource: str,
    name: Optional[str] = None,
    namespace: Optional[str] = None,
    output: str = "wide"
) -> str:
    """
    Get Kubernetes resources.
    
    Args:
        resource: Resource type (pods, services, deployments, etc.)
        name: Specific resource name
        namespace: Namespace (default: current context namespace)
        output: Output format (wide, json, yaml)
    """
    cmd = ["kubectl", "get", resource]
    if name:
        cmd.append(name)
    if namespace:
        cmd.extend(["-n", namespace])
    cmd.extend(["-o", output])
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def kubectl_describe(
    resource: str,
    name: str,
    namespace: Optional[str] = None
) -> str:
    """
    Describe a Kubernetes resource.
    
    Args:
        resource: Resource type (pod, service, deployment, etc.)
        name: Resource name
        namespace: Namespace
    """
    cmd = ["kubectl", "describe", resource, name]
    if namespace:
        cmd.extend(["-n", namespace])
    
    result = await run_command(cmd)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def kubectl_logs(
    pod: str,
    namespace: Optional[str] = None,
    container: Optional[str] = None,
    tail: Optional[int] = None,
    follow: bool = False
) -> str:
    """
    Get logs from a Kubernetes pod.
    
    Args:
        pod: Pod name
        namespace: Namespace
        container: Container name (for multi-container pods)
        tail: Number of lines to show
        follow: Follow log output
    """
    cmd = ["kubectl", "logs", pod]
    if namespace:
        cmd.extend(["-n", namespace])
    if container:
        cmd.extend(["-c", container])
    if tail:
        cmd.extend(["--tail", str(tail)])
    if follow:
        cmd.append("-f")
    
    timeout = None if follow else 30
    result = await run_command(cmd, timeout=timeout)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def kubectl_apply(file: str, namespace: Optional[str] = None) -> str:
    """
    Apply a Kubernetes manifest.
    
    Args:
        file: Path to manifest file or URL
        namespace: Namespace to apply to
    """
    cmd = ["kubectl", "apply", "-f", file]
    if namespace:
        cmd.extend(["-n", namespace])
    
    result = await run_command(cmd, timeout=60)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def kubectl_delete(
    resource: str,
    name: str,
    namespace: Optional[str] = None
) -> str:
    """
    Delete a Kubernetes resource.
    
    Args:
        resource: Resource type
        name: Resource name
        namespace: Namespace
    """
    cmd = ["kubectl", "delete", resource, name]
    if namespace:
        cmd.extend(["-n", namespace])
    
    result = await run_command(cmd, timeout=60)
    return result.stdout.strip()

@mcp.tool()
@handle_errors
async def kubectl_exec(
    pod: str,
    command: str,
    namespace: Optional[str] = None,
    container: Optional[str] = None,
    interactive: bool = False
) -> str:
    """
    Execute a command in a Kubernetes pod.
    
    Args:
        pod: Pod name
        command: Command to execute
        namespace: Namespace
        container: Container name (for multi-container pods)
        interactive: Allocate a TTY
    """
    cmd = ["kubectl", "exec", pod]
    if namespace:
        cmd.extend(["-n", namespace])
    if container:
        cmd.extend(["-c", container])
    if interactive:
        cmd.append("-it")
    cmd.append("--")
    cmd.extend(command.split())
    
    result = await run_command(cmd)
    return result.stdout.strip()
```

### 4.6 Main Entry Point

```python
def main():
    """Main entry point for the MCP server."""
    import sys
    
    # Run the FastMCP server with stdio transport
    mcp.run(transport="stdio")

if __name__ == "__main__":
    main()
```

## 5. Registration with Claude Code

### 5.1 MCP Settings Configuration

Add to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "orbstack": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/Ezra/mcp-orbstack",
        "run",
        "server.py"
      ],
      "description": "OrbStack, Docker, and Kubernetes management"
    }
  }
}
```

### 5.2 Alternative Registration (if installed globally)

```json
{
  "mcpServers": {
    "orbstack": {
      "command": "mcp-orbstack",
      "description": "OrbStack, Docker, and Kubernetes management"
    }
  }
}
```

## 6. Testing Strategy

### 6.1 Manual Testing Checklist

**OrbStack System:**
- [ ] `orb_status` - Verify status reporting
- [ ] `orb_version` - Check version output
- [ ] `orb_config_show` - View configuration
- [ ] `orb_config_set` - Set and verify a config option
- [ ] `orb_doctor` - Run diagnostics

**Linux Machines:**
- [ ] `orb_list_machines` - List with text and JSON format
- [ ] `orb_create_machine` - Create Ubuntu and Alpine machines
- [ ] `orb_machine_info` - Get info on created machine
- [ ] `orb_start_machine` / `orb_stop_machine` - Control lifecycle
- [ ] `orb_run_command` - Execute commands
- [ ] `orb_push_file` / `orb_pull_file` - File transfers
- [ ] `orb_delete_machine` - Clean up test machines

**Docker:**
- [ ] `docker_ps` - List containers (empty and with containers)
- [ ] `docker_images` - List images
- [ ] `docker_run` - Start nginx container
- [ ] `docker_logs` - View container logs
- [ ] `docker_exec` - Run command in container
- [ ] `docker_stop` / `docker_rm` - Stop and remove
- [ ] `docker_pull` - Pull small image
- [ ] `docker_volume_ls` / `docker_network_ls` - List resources
- [ ] `docker_compose_up` / `docker_compose_down` - Test compose

**Docker Extensions:**
- [ ] `orb_docker_volume_clone` - Clone a test volume

**Kubernetes:**
- [ ] `orb_k8s_start` - Start K8s cluster
- [ ] `kubectl_get` - Get pods, services
- [ ] `kubectl_apply` - Deploy test manifest
- [ ] `kubectl_logs` - View pod logs
- [ ] `kubectl_exec` - Execute in pod
- [ ] `kubectl_delete` - Remove resources
- [ ] `orb_k8s_stop` - Stop cluster

### 6.2 Test Script

Create a `test_tools.py` for basic validation:

```python
#!/usr/bin/env python3
"""
Basic smoke tests for MCP OrbStack server.
Run with: uv run test_tools.py
"""

import asyncio
from server import (
    orb_status, orb_version, orb_list_machines,
    docker_ps, docker_images, docker_volume_ls,
    kubectl_get
)

async def run_tests():
    print("Testing OrbStack MCP Server Tools\n")
    
    # Test OrbStack
    print("1. OrbStack Status:")
    print(await orb_status())
    print()
    
    print("2. OrbStack Version:")
    print(await orb_version())
    print()
    
    print("3. List Machines (text):")
    print(await orb_list_machines(format="text"))
    print()
    
    print("4. List Machines (JSON):")
    print(await orb_list_machines(format="json"))
    print()
    
    # Test Docker
    print("5. Docker Containers:")
    print(await docker_ps(all=True))
    print()
    
    print("6. Docker Images:")
    print(await docker_images())
    print()
    
    print("7. Docker Volumes:")
    print(await docker_volume_ls())
    print()
    
    # Test Kubernetes (if running)
    print("8. Kubernetes Pods:")
    try:
        print(await kubectl_get("pods", namespace="default"))
    except Exception as e:
        print(f"K8s not running or error: {e}")
    print()
    
    print("All tests completed!")

if __name__ == "__main__":
    asyncio.run(run_tests())
```

### 6.3 Claude Code Integration Test

1. Add server to `~/.claude/mcp.json`
2. Restart Claude Code
3. Test with prompts:
   - "List all OrbStack machines"
   - "Show me running Docker containers"
   - "Create an Ubuntu machine named test-machine"
   - "Run 'uname -a' on the default machine"
   - "Start a nginx container on port 8080"
   - "Get all Kubernetes pods"

## 7. Implementation Sequence

### Phase 1: Project Setup (15 minutes)
1. Create project directory: `/Users/Ezra/mcp-orbstack`
2. Initialize with `uv init`
3. Create `pyproject.toml` with dependencies
4. Create `.gitignore` and `.python-version`
5. Initialize git repository

### Phase 2: Core Infrastructure (30 minutes)
1. Create `server.py` with FastMCP setup
2. Implement `run_command()` async helper
3. Implement `run_json_command()` helper
4. Implement `handle_errors()` decorator
5. Test basic command execution

### Phase 3: OrbStack Tools (45 minutes)
1. Implement system tools (status, version, config, doctor)
2. Implement machine management tools
3. Implement file transfer tools (push/pull)
4. Test all OrbStack tools

### Phase 4: Docker Tools (60 minutes)
1. Implement basic Docker commands (ps, images, logs, inspect)
2. Implement container lifecycle (run, exec, stop, rm)
3. Implement image operations (pull, build, rmi)
4. Implement Docker Compose tools
5. Implement volume and network listing
6. Test all Docker tools

### Phase 5: Docker Extensions (15 minutes)
1. Implement volume clone
2. Implement debug tool
3. Test extensions

### Phase 6: Kubernetes Tools (45 minutes)
1. Implement cluster control (start/stop)
2. Implement kubectl get/describe
3. Implement kubectl logs/exec
4. Implement kubectl apply/delete
5. Test all K8s tools

### Phase 7: Integration & Testing (60 minutes)
1. Register with Claude Code
2. Create test script
3. Run manual testing checklist
4. Test through Claude Code interface
5. Fix any issues found
6. Document usage patterns

### Phase 8: Documentation (30 minutes)
1. Write comprehensive README.md
2. Document all tools with examples
3. Add troubleshooting section
4. Add contribution guidelines

**Total Estimated Time: 4-5 hours**

## 8. Error Handling & Edge Cases

### 8.1 Common Scenarios to Handle

1. **OrbStack Not Running**
   - Commands will fail with "OrbStack is not running"
   - Error decorator catches and returns friendly message

2. **Command Not Found**
   - FileNotFoundError when CLI not in PATH
   - Return message about installation

3. **Timeouts**
   - Long-running operations (build, pull, create)
   - Use appropriate timeout values per command

4. **Invalid Arguments**
   - Let the CLI tools validate (they have better error messages)
   - Pass through stderr to user

5. **JSON Parsing Failures**
   - Handle malformed JSON from --format json
   - Return raw output if parsing fails

6. **Permission Issues**
   - Docker socket permissions
   - File access for push/pull

### 8.2 Timeout Configuration

- System commands: 5-10 seconds
- List/info commands: 30 seconds
- Create/start/stop: 60-120 seconds
- Build/pull/compose: 300-600 seconds
- Logs with follow: No timeout (streaming)

## 9. Future Enhancements (Post-MVP)

### 9.1 Potential Additions

1. **Resource Prompts/Resources**
   - Expose machine configs as resources
   - Expose docker-compose files as resources
   - Expose k8s manifests as resources

2. **Streaming Support**
   - Stream logs in real-time
   - Stream build output
   - Progress indicators for long operations

3. **Batch Operations**
   - Start/stop multiple machines
   - Clean up all stopped containers
   - Bulk delete operations

4. **Advanced Docker Features**
   - Docker swarm commands
   - Multi-stage build support
   - Registry management

5. **Advanced Kubernetes Features**
   - Helm chart deployment
   - Port forwarding
   - Context switching
   - Namespace management

6. **Monitoring & Status**
   - Resource usage (CPU, memory)
   - Container health checks
   - Machine statistics

### 9.2 Performance Optimizations

1. **Caching**
   - Cache machine list for 5-10 seconds
   - Cache image list to reduce calls

2. **Parallel Execution**
   - Allow multiple operations concurrently
   - Batch similar operations

3. **Output Formatting**
   - Parse and format table outputs
   - Colorize output for better readability

## 10. Security Considerations

1. **Command Injection**
   - Use list-based subprocess arguments (not shell=True)
   - Avoid string interpolation in commands
   - Validate/sanitize user inputs where necessary

2. **File Path Validation**
   - Validate paths for push/pull operations
   - Prevent directory traversal attacks
   - Check file permissions

3. **Resource Limits**
   - Implement reasonable timeouts
   - Prevent infinite loops in follow mode
   - Limit output sizes if needed

## 11. Deployment Checklist

- [ ] Create project directory structure
- [ ] Set up pyproject.toml with correct dependencies
- [ ] Implement all 50+ tools in server.py
- [ ] Add comprehensive error handling
- [ ] Create test script
- [ ] Write README.md with examples
- [ ] Register in ~/.claude/mcp.json
- [ ] Test all OrbStack tools
- [ ] Test all Docker tools
- [ ] Test all Kubernetes tools
- [ ] Verify Claude Code integration
- [ ] Document known limitations
- [ ] Create .gitignore and version files
- [ ] Initialize git repository
- [ ] Tag v0.1.0 release

## Summary

This implementation plan provides a comprehensive, production-ready MCP server for OrbStack that:

1. **Uses a single-file architecture** for simplicity (800-1000 LOC)
2. **Leverages FastMCP** for easy server creation
3. **Implements all 50+ requested tools** across 5 categories
4. **Uses async subprocess** for efficient command execution
5. **Has robust error handling** with user-friendly messages
6. **Supports JSON output** where available for structured data
7. **Integrates seamlessly** with Claude Code via stdio transport
8. **Is well-tested** with comprehensive testing strategy
9. **Is maintainable** with clear patterns and documentation

The server will enable Claude to perform all OrbStack, Docker, and Kubernetes operations directly, making it a powerful development companion for container and VM management.
