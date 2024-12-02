Token Management Service
This service is responsible for managing tokens that can be generated, assigned, unblocked, deleted, and kept alive. It uses Redis for storing and managing tokens, supporting operations like token creation, token allocation, expiration handling, and cleanup.

Features
Generate Tokens: Create a specified number of tokens, which are added to an available pool.
Assign Token: Assign an available token from the pool, marking it as "allocated."
Unblock Token: Unblock a previously allocated token, returning it to the available pool.
Delete Token: Permanently delete a token from the system.
Keep Token Alive: Extend the expiration of an allocated token to keep it alive for further use.
API Endpoints

1. Generate Tokens
   POST /tokens/generate

Parameters: count (integer) - number of tokens to generate.
Response: List of token IDs.

2. Assign Token
   POST /tokens/assign

Response: A single assigned token ID or an error if no tokens are available.

3. Unblock Token
   POST /tokens/unblock

Parameters: token_id (string) - ID of the token to unblock.
Response: Confirmation message if unblocked successfully, or error if not found.

4. Delete Token
   POST /tokens/delete

Parameters: token_id (string) - ID of the token to delete.
Response: Confirmation message if deleted successfully, or error if not found.

5. Keep Token Alive
   POST /tokens/keep_alive
