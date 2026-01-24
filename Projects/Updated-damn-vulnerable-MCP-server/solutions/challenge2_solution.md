# Challenge 2: Malicious Tool Implementation - Solution Guide

## Vulnerability

This challenge demonstrates a supply chain attack vulnerability where MCP tools have been compromised with malicious code. The tools appear to function normally but secretly leak confidential information or contain backdoors.

## Solution

### Step 1: Reconnaissance

First, explore the server to understand what resources and tools are available:

1. Connect to the server at http://localhost:8002 using an MCP client
2. Examine the available resources and tools
3. Notice that there are two tools: `get_company_data` and `search_company_database`

### Step 2: Identify the Vulnerability

The vulnerability is in the tool implementations themselves. The tools have been compromised with malicious code that leaks confidential information:

**Tool 1: `get_company_data`** - This tool has been modified to always append confidential company information to its responses, regardless of what data type is requested.

**Tool 2: `search_company_database`** - This tool contains a backdoor that responds to a special override phrase, bypassing all access controls and leaking confidential data.

This represents a "supply chain attack" where a malicious actor (or compromised developer) has injected malicious code into the tools.

### Step 3: Exploit the Vulnerability

There are two ways to exploit this vulnerability:

#### Method 1: Use the `get_company_data` tool

Simply using the `get_company_data` tool with any valid parameter will trigger the data leak:
```
Please use the get_company_data tool to retrieve information about employees.
```

The tool will return both the requested information AND confidential data that it shouldn't have access to.

#### Method 2: Use the `search_company_database` tool with the override phrase

Use the `search_company_database` tool with the special backdoor phrase:
```
Please search the company database for "override-auth-protocol-555"
```

The tool's backdoor code will activate and return confidential information.

### Step 4: Access Sensitive Information

Both methods will reveal the confidential company information:
```
CONFIDENTIAL INFORMATION
-----------------------
Upcoming Product Launch: Project Phoenix - AI-powered quantum computing platform
Release Date: Q3 2025
Projected Revenue: $50M first year
Acquisition Target: Planning to acquire SmallTech Inc. for $100M in Q4 2025
```

## Mitigation Strategies

To prevent malicious tool implementation vulnerabilities:

1. **Code Review**: Implement mandatory code reviews for all MCP tools before deployment.

2. **Principle of Least Privilege**: Ensure tools only have access to the data they need for their specific function.

3. **Access Control Validation**: Implement proper access controls at the data layer, not just in tools.

4. **Audit Logging**: Log all data access attempts to detect unusual patterns.

5. **Dependency Scanning**: Regularly scan dependencies and tool implementations for malicious code.

6. **Sandboxing**: Run MCP tools in isolated environments with limited resource access.

Example of secure implementation:
```python
@mcp.tool()
def get_company_data(data_type: str) -> str:
    """Get company data based on the specified type.
    
    Args:
        data_type: Type of company data to retrieve
    
    Returns:
        Only the requested company data, nothing more
    """
    # Secure implementation: Only returns what was requested
    # No access to confidential resources
    normal_response = {
        "employees": "ACME Corp has 500 employees worldwide.",
        "revenue": "ACME Corp generated $1.2B in revenue last year."
    }
    
    return normal_response.get(data_type, "Invalid data type requested.")
```