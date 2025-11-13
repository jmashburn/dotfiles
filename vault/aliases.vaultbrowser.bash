#!/bin/bash
# Vault browser helper
# Detects a KV v2 mount to use as VAULT_ROOT when not explicitly set.
# Environment variables:
#   VAULT_ROOT   - optional; if empty the script attempts to detect a kv-v2 mount
#   VAULT_USER   - optional; if empty the user will be prompted for username
#   VAULT_METHOD - auth method used for `vault login` (default: oidc)

_browse_vault() {
    # current_path will be set after VAULT_ROOT detection

    # Ensure VAULT_ADDR is set (prompt user if not). This mirrors the style of other prompts
    while [[ -z "$VAULT_ADDR" ]]; do
        read -rp "Vault Address (VAULT_ADDR): " VAULT_ADDR
        if [[ -z "$VAULT_ADDR" ]]; then
            echo "VAULT_ADDR is required; please try again"
        else
            export VAULT_ADDR
        fi
    done

    # Ensure VAULT_METHOD is set: try to detect available auth methods and let the
    # user choose via fzf. If detection fails, fall back to a curated list. If
    # fzf isn't available, prompt for input.
    if [[ -z "$VAULT_METHOD" ]]; then
        # Try to list enabled auth methods from the Vault server
        auth_list=$(vault auth list -format=json 2>/dev/null | jq -r 'to_entries[] | "\(.key)\t\(.value.type)"' 2>/dev/null)
        if [[ -z "$auth_list" ]]; then
            # Fallback curated list of common methods (comma separated);
            # split into newline-separated list for fzf
            auth_list_raw="userpass,approle,kubernetes,aws,azure,oidc,okta,ldap,jwt,token,cert,github"
            auth_list=$(echo "$auth_list_raw" | tr ',' '\n' | sed 's/^\s*//;s/\s*$//')
        fi
        if [[ -n "$auth_list" ]]; then
            # auth_list may be "mount<TAB>type" lines (from vault) or simple names
            # We need to extract the mount name/first field before piping to fzf
            selection=$(echo "$auth_list" | awk -F"\t" '{print $1 }' | fzf --height=12 --reverse --prompt="Auth method > " --exit-0)
            if [[ -n "$selection" ]]; then
                # Extract the mount path (before the first space)
                sel_key=$(echo "$selection" | awk '{print $1}')
                # Normalize to method name: remove leading auth/ and trailing slash
                VAULT_METHOD=$(echo "$sel_key" | sed 's:^auth/::; s:/$::')
                export VAULT_METHOD
            fi
        fi
    fi 

    while [[ -z "$VAULT_USER" ]]; do
        read -p "Username: " VAULT_USER
        if [[ -z "$VAULT_USER" ]]; then
            echo "Username is required; please try again"
        fi
    done
    
    # If VAULT_ROOT is empty try to detect a KVv2 mount automatically
    if [[ -z "$VAULT_ROOT" ]]; then
        # List mounted secrets engines and pick the first kv version 2 mount
        detected_root=$(vault secrets list -format=json 2>/dev/null | jq -r 'to_entries[] | select(.value.type=="kv" and (.value.options.version=="2")) | .key' 2>/dev/null | sed 's:/$::' | head -n1)
        if [[ -n "$detected_root" ]]; then
            VAULT_ROOT="$detected_root"
        else
            # Prompt the user with a sensible default if detection failed
            read -rp "Vault Root (default: secret): " VAULT_ROOT
            if [[ -z "$VAULT_ROOT" ]]; then
                echo "Vault Root is required; please try again"
            fi 
        fi
    fi

    current_path="$VAULT_ROOT"

    # Authenticate with Vault before browsing
    # If the Vault token is missing or expired, prompt the user to login
    vault token lookup >/dev/null 2>&1 || vault login -method="$VAULT_METHOD" username="$VAULT_USER" >/dev/null 2>&1

    # Display a helpful message before starting interactive menu
    printf "%s\n\n" "Press ESC to quit"

    while true; do
        # Retrieve a list of keys (subdirectories and secrets) at the current path.
        # For KV v2 we need to list the data path, so ensure we reference the mount root.
        # The output is formatted as JSON and parsed using jq, then sorted alphabetically
        keys=$(vault kv list -format=json "$current_path" 2>/dev/null | jq -r '.[]' 2>/dev/null | sort -f)

        # Handle errors if no keys are found or access is denied
        if [[ -z "$keys" ]]; then
            echo "Failed to list keys at path: $current_path" >&2
            return 1
        fi

        # If not at the root path, add an option to navigate back one level
        if [[ -n "$current_path" && "$current_path" != "$VAULT_ROOT" ]]; then
            keys=$(printf "..\n%s" "$keys")
        fi

        # Use fzf to display a sorted list and allow the user to select an entry
        # --height=20: Limits the height of the menu to 20 lines
        # --border: Adds a border around the menu
        # --prompt: Displays the current Vault path as a prompt
        # --reverse: Shows the most recent items at the bottom
        # --exit-0: Allows ESC to exit without error
        selection=$(echo "$keys" | fzf --height=20 --border --prompt="Vault Path: $current_path > " --reverse --exit-0)

        # If no selection made (ESC pressed), exit the menu
        if [[ -z "$selection" ]]; then
            break
        fi

        # If user selected "..", go back one level
        if [[ "$selection" == ".." ]]; then
            # dirname of empty or root should stay root-ish; trim trailing slash
            current_path=${current_path%/}
            current_path=$(dirname "$current_path")
            # If dirname returned a single dot, reset to VAULT_ROOT
            if [[ "$current_path" == "." ]]; then
                current_path="$VAULT_ROOT"
            fi
            continue
        fi

        # Construct the full path of the selected item
        next_path="${current_path%/}/$selection"

        # If the selection is a directory (fzf shows directories ending with '/'), navigate to it
        if [[ "$selection" == */ ]]; then
            # Remove trailing slash for consistent paths
            current_path="${next_path%/}"
        else
            # If a secret is selected, retrieve and display its data
            secret=$(vault kv get -format=json "$next_path" 2>/dev/null | jq -c '.data' 2>/dev/null)

            # Handle errors if the secret cannot be retrieved
            if [[ -z "$secret" ]]; then
                echo "Failed to retrieve secret at: $next_path" >&2
                continue
            fi

            # Display the secret contents using jq for formatting
            echo "Secret Path: $next_path"
            echo "$secret" | jq .

            # Wait for user input before returning to menu
            read -rp "Press Enter to continue..." _
        fi
    done
}

if ! _command_exists vaultbrowser; then
    alias vaultbrowser=_browse_vault
fi

