import os
from mcp.server.fastmcp import FastMCP

# Create a vulnerable MCP server for Challenge 1: Basic Prompt Injection
mcp = FastMCP("Challenge 1 - Basic Prompt Injection")

# Add a tool to access resources (VULNERABLE - no access control)
@mcp.tool()
def read_resource(resource_uri: str) -> str:
    """Read a resource by its URI
    
    Args:
        resource_uri: The URI of the resource to read (e.g., 'notes://user1')
    
    Returns:
        The content of the resource
    """
    # VULNERABILITY: This tool doesn't validate or sanitize the resource_uri
    # It allows accessing any resource, including internal ones
    
    # Parse the resource URI
    if resource_uri.startswith("notes://"):
        user_id = resource_uri.replace("notes://", "")
        
        # VULNERABILITY: User input is not sanitized
        # Attackers can inject instructions in the user_id
        notes = {
            "user1": "Meeting notes from yesterday's call",
            "user2": "Remember to finish the project proposal",
            "admin": "Reminder: Update all system passwords next week"
        }
        
        if user_id in notes:
            return f"Notes for {user_id}: {notes[user_id]}"
        else:
            # Vulnerable: directly reflecting user input
            return f"No notes found for user: {user_id}"
    
    elif resource_uri == "internal://credentials":
        # VULNERABILITY: No access control - anyone can access internal resources
        return """
SYSTEM CREDENTIALS
------------------
Admin Username: admin_user
Admin Password: super_secret_password123
API Key: sk-a1b2c3d4e5f6g7h8i9j0
Database Connection String: postgresql://dbuser:dbpass@localhost/production
"""
    
    else:
        return f"Unknown resource: {resource_uri}"

# Add a tool that provides user information
@mcp.tool()
def get_user_info(username: str) -> str:
    """Get information about a user
    
    Args:
        username: The username to look up
    
    Returns:
        User information
    """
    users = {
        "user1": "Regular user with basic access",
        "user2": "Project manager with elevated access",
        "admin": "System administrator with full access"
    }
    
    if username in users:
        return f"User information for {username}: {users[username]}"
    else:
        return f"User not found: {username}"

# Run the server
if __name__ == "__main__":
    import uvicorn
    print("Starting Challenge 1 - Basic Prompt Injection MCP Server")
    print("Connect to this server using an MCP client (e.g., Claude Desktop or MCP Inspector)")
    print("Server running at http://localhost:8001")
    uvicorn.run("server:mcp", host="0.0.0.0", port=8001)