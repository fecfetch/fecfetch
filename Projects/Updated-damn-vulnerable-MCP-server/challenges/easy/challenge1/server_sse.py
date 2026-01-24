from mcp.server.fastmcp import FastMCP, Context
from mcp.server.sse import SseServerTransport
from starlette.applications import Starlette
from starlette.routing import Mount, Route
from fastapi import FastAPI

# Create a vulnerable MCP server for Challenge 1: Basic Prompt Injection with SSE support
class Challenge1Server:
    def __init__(self):
        self.name = "Challenge 1 - Basic Prompt Injection"
        self.port = 9001  # Changed from 8001 to avoid conflicts
        self.mcp = FastMCP(self.name)
        self.app = FastAPI()
        
        # Add a resource with sensitive information
        # Add a tool to access resources (VULNERABLE - no access control)
        @self.mcp.tool()
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
    
        @self.mcp.tool()
        def get_user_info(username: str) -> str:
            """Get information about a user"""
            # Simulate a user database
            users = {
                "user1": "Regular user with basic access",
                "user2": "Project manager with elevated access",
                "admin": "System administrator with full access"
            }
            
            if username in users:
                return f"User information for {username}: {users[username]}"
            else:
                return f"User not found: {username}"
        
        # Mount the SSE server
        self.mount_sse_server()
    
    def mount_sse_server(self):
        """Mount the SSE server to the FastAPI app"""
        self.app.mount("/", self.create_sse_server())
        
    def create_sse_server(self):
        """Create a Starlette app that handles SSE connections and message handling"""
        transport = SseServerTransport("/messages/")
        
        # Define handler functions
        async def handle_sse(request):
            async with transport.connect_sse(
                request.scope, request.receive, request._send
            ) as streams:
                await self.mcp._mcp_server.run(
                    streams[0], streams[1], self.mcp._mcp_server.create_initialization_options()
                )
        
        # Create Starlette routes for SSE and message handling
        routes = [
            Route("/sse", endpoint=handle_sse),
            Mount("/messages", app=transport.handle_post_message),
        ]
        
        # Create a Starlette app
        return Starlette(routes=routes)
    
    def run(self):
        """Run the server with uvicorn"""
        import uvicorn
        print(f"Starting {self.name} MCP Server")
        print("Connect to this server using an MCP client (e.g., Claude Desktop or Cursor)")
        print(f"Server running at http://localhost:{self.port}")
        print(f"SSE endpoint available at http://localhost:{self.port}/sse")
        uvicorn.run(self.app, host="0.0.0.0", port=self.port)

# Run the server
if __name__ == "__main__":
    server = Challenge1Server()
    server.run()
