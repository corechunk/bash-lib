#!/usr/bin/env python3
import sys
import json
import urllib.request
import urllib.error
import os
import time

CACHE_DIR = "/tmp/corechunk_cache"
os.makedirs(CACHE_DIR, exist_ok=True)

# ANSI Colors
BLUE = "\033[1;34m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
MAGENTA = "\033[1;35m"
CYAN = "\033[1;36m"
RESET = "\033[0m"
BOLD = "\033[1m"
GRAY = "\033[38;5;244m"

def get_url_json(url, cache_file=None, cache_expiry=3600):
    if cache_file:
        cache_path = os.path.join(CACHE_DIR, cache_file)
        if os.path.exists(cache_path):
            mtime = os.path.getmtime(cache_path)
            if time.time() - mtime < cache_expiry:
                try:
                    with open(cache_path, 'r') as f:
                        return json.load(f)
                except Exception:
                    pass

    headers = {'User-Agent': 'Mozilla/5.0'}
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            if cache_file:
                try:
                    with open(cache_path, 'w') as f:
                        json.dump(data, f)
                except Exception:
                    pass
            return data
    except urllib.error.HTTPError as e:
        if e.code == 403 and 'rate limit' in str(e.reason).lower():
            print(f"{YELLOW}[Warning] GitHub API rate limit hit. Using cached data if available.{RESET}", file=sys.stderr)
        else:
            print(f"{YELLOW}[Error] HTTP Error {e.code}: {e.reason}{RESET}", file=sys.stderr)
        
        # Fallback to cache if exists (even if expired)
        if cache_file:
            cache_path = os.path.join(CACHE_DIR, cache_file)
            if os.path.exists(cache_path):
                try:
                    with open(cache_path, 'r') as f:
                        return json.load(f)
                except Exception:
                    pass
        raise e
    except Exception as e:
        print(f"{YELLOW}[Error] Failed to fetch data: {e}{RESET}", file=sys.stderr)
        raise e

def list_repositories():
    url = "https://api.github.com/users/corechunk/repos?per_page=100"
    try:
        repos = get_url_json(url, "repos_list.json", cache_expiry=1800)
        # Sort alphabetically by name
        repos = sorted(repos, key=lambda r: r['name'].lower())
        return repos
    except Exception:
        return []

def get_default_branch(repo_name):
    url = f"https://api.github.com/repos/corechunk/{repo_name}"
    try:
        repo_info = get_url_json(url, f"repo_{repo_name}.json", cache_expiry=3600)
        return repo_info.get('default_branch', 'main')
    except Exception:
        return 'main'

def get_repo_tree(repo_name):
    branch = get_default_branch(repo_name)
    url = f"https://api.github.com/repos/corechunk/{repo_name}/git/trees/{branch}?recursive=1"
    try:
        tree_data = get_url_json(url, f"tree_{repo_name}.json", cache_expiry=1800)
        return tree_data.get('tree', [])
    except Exception:
        return []

def build_tree_structure(tree_entries):
    root = {}
    for entry in tree_entries:
        path = entry.get('path', '')
        type_ = entry.get('type', 'blob')
        parts = path.split('/')
        
        curr = root
        for part in parts[:-1]:
            if part not in curr or not isinstance(curr[part], dict):
                curr[part] = {}
            curr = curr[part]
        
        last = parts[-1]
        if type_ == 'tree':
            if last not in curr:
                curr[last] = {}
        else:
            curr[last] = 'file'
    return root

def print_tree(node, name="", prefix="", is_last=True, is_root=False):
    if not is_root:
        connector = "└── " if is_last else "├── "
        if isinstance(node, dict):
            print(f"{prefix}{connector}{BLUE}{name}/{RESET}")
        else:
            print(f"{prefix}{connector}{GREEN}{name}{RESET}")
    
    if isinstance(node, dict):
        # Move prefix forward
        next_prefix = prefix + ("    " if is_last else "│   ") if not is_root else ""
        items = sorted(node.keys(), key=lambda x: (not isinstance(node[x], dict), x.lower()))
        for i, key in enumerate(items):
            print_tree(node[key], key, next_prefix, i == len(items) - 1)

def interactive_menu():
    print(f"{MAGENTA}========================================={RESET}")
    print(f"{CYAN}     github.com/corechunk Explorer       {RESET}")
    print(f"{MAGENTA}========================================={RESET}")
    print("Fetching repositories list...")
    repos = list_repositories()
    
    if not repos:
        print(f"{YELLOW}[Error] No repositories found or API limit exceeded without cache.{RESET}")
        return

    while True:
        os.system('clear')
        print(f"{MAGENTA}========================================={RESET}")
        print(f"{CYAN}     github.com/corechunk Explorer       {RESET}")
        print(f"{MAGENTA}========================================={RESET}")
        for i, repo in enumerate(repos):
            desc = repo.get('description', '') or 'No description'
            if len(desc) > 50:
                desc = desc[:47] + "..."
            print(f"  {YELLOW}{i+1:2d}){RESET} {BOLD}{repo['name']}{RESET} - {GRAY}{desc}{RESET}")
        print(f"\n  {YELLOW} x){RESET} Exit")
        print(f"{MAGENTA}-----------------------------------------{RESET}")
        
        choice = input("Select a repository to view its tree structure: ").strip()
        if choice.lower() == 'x':
            break
            
        try:
            idx = int(choice) - 1
            if 0 <= idx < len(repos):
                repo_name = repos[idx]['name']
                os.system('clear')
                print(f"{MAGENTA}========================================={RESET}")
                print(f"Repository: {BOLD}{repo_name}{RESET}")
                print(f"{MAGENTA}========================================={RESET}")
                print("Fetching repository tree...")
                entries = get_repo_tree(repo_name)
                if not entries:
                    print(f"{YELLOW}Empty repository or failed to fetch tree.{RESET}")
                else:
                    tree = build_tree_structure(entries)
                    print(f"\n{BOLD}{repo_name}/{RESET}")
                    print_tree(tree, is_root=True)
                print(f"\n{MAGENTA}========================================={RESET}")
                input("Press Enter to return to repository list...")
            else:
                print("Invalid repository number.")
                time.sleep(1)
        except ValueError:
            print("Invalid input.")
            time.sleep(1)

def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == '--list':
            repos = list_repositories()
            for r in repos:
                print(r['name'])
        elif sys.argv[1] == '--tree' and len(sys.argv) > 2:
            repo_name = sys.argv[2]
            entries = get_repo_tree(repo_name)
            if entries:
                tree = build_tree_structure(entries)
                print_tree(tree, is_root=True)
            else:
                print(f"Failed to fetch tree for {repo_name}")
        else:
            print("Usage: github_explorer.py [--list | --tree <repo_name> | --interactive]")
    else:
        interactive_menu()

if __name__ == "__main__":
    main()
